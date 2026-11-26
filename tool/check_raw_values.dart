// Design-token gate: fails if raw style values appear outside lib/theme/.
//
// Usage:  dart run tool/check_raw_values.dart
// Exit code 0 = clean, 1 = violations found.
//
// Enforced as a green gate from Phase 3 onward. In Phase 1 the existing code
// still contains raw values (expected), so this reports a baseline and exits 1.
import 'dart:io';

final _rules = <String, RegExp>{
  'Color(0x': RegExp(r'Color\(0x'),
  // Only flag Duration used as an animation property, not logic (Timer/date math).
  'duration: Duration(': RegExp(r'duration:\s*(?:const\s+)?Duration\('),
  'BorderRadius.circular(<num>)': RegExp(r'BorderRadius\.circular\(\s*\d'),
  // Warn-only (style smells):
  'EdgeInsets.all(<num>)': RegExp(r'EdgeInsets\.all\(\s*\d'),
};

bool _isThemeFile(String path) {
  final p = path.replaceAll('\\', '/');
  return p.contains('lib/theme/');
}

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Run from the project root (lib/ not found).');
    exit(2);
  }

  final violations = <String>[];
  final warnings = <String>[];
  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !_isThemeFile(f.path));

  for (final file in files) {
    final rel = file.path.replaceAll('\\', '/');
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final entry in _rules.entries) {
        if (entry.value.hasMatch(line)) {
          final isWarn = entry.key.startsWith('EdgeInsets');
          final msg = '${isWarn ? '' : '✗ '}$rel:${i + 1}  [${entry.key}]  ${line.trim()}';
          (isWarn ? warnings : violations).add(msg);
        }
      }
    }
  }

  if (warnings.isNotEmpty) {
    stdout.writeln('Warnings (non-fatal) — ${warnings.length}:');
    for (final w in warnings.take(15)) {
      stdout.writeln('  ⚠ $w');
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('\n✅ check_raw_values: no raw Color(0x/Duration/BorderRadius.circular outside lib/theme/.');
    exit(0);
  }

  stdout.writeln('\n❌ check_raw_values: ${violations.length} raw value(s) outside lib/theme/:');
  for (final v in violations) {
    stdout.writeln('  $v');
  }
  exit(1);
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

/// PIN/biometric lock screen (US8). 3 strikes -> 30s cooldown.
class LockScreen extends StatefulWidget {
  final String pinHash;
  final void Function() onUnlocked;

  const LockScreen({
    super.key,
    required this.pinHash,
    required this.onUnlocked,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _entered = '';
  int _strikes = 0;
  bool _locked = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _onDigit(int digit) {
    if (_locked) return;
    HapticFeedback.lightImpact();
    setState(() => _entered += digit.toString());
    if (_entered.length == widget.pinHash.length) {
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_entered == widget.pinHash) {
      widget.onUnlocked();
    } else {
      setState(() {
        _strikes++;
        _entered = '';
      });
      if (_strikes >= 3) {
        _startCooldown();
      }
    }
  }

  void _startCooldown() {
    setState(() {
      _locked = true;
      _cooldownSeconds = 30;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) {
        t.cancel();
        setState(() {
          _locked = false;
          _strikes = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoovaTheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: NoovaTheme.accent),
            const SizedBox(height: 16),
            Text(
              _locked ? 'Espera \$_cooldownSeconds s' : 'Ingresa tu PIN',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.pinHash.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _entered.length
                        ? NoovaTheme.accent
                        : NoovaTheme.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Keypad
            for (var row = 0; row < 3; row++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final digit = row * 3 + i + 1;
                    return _keyButton(digit);
                  }),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 72),
                  _keyButton(0),
                  _backspaceButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyButton(int digit) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: _locked ? null : () => _onDigit(digit),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: NoovaTheme.surface,
          ),
          alignment: Alignment.center,
          child: Text(
            '$digit',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  Widget _backspaceButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: _locked || _entered.isEmpty
            ? null
            : () => setState(() => _entered = _entered.substring(0, _entered.length - 1)),
        borderRadius: BorderRadius.circular(40),
        child: const SizedBox(
          width: 64,
          height: 64,
          child: Icon(Icons.backspace_outlined, size: 24),
        ),
      ),
    );
  }
}

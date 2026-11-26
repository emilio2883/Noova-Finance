import 'package:flutter/material.dart';

/// Elevation/shadow tokens. Soft, low-opacity navy shadows per the reference.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = <BoxShadow>[];

  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x140B2C45),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F0B2C45),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Coral glow behind primary CTA pills (reference "Pay Now").
  static const List<BoxShadow> ctaGlow = <BoxShadow>[
    BoxShadow(
      color: Color(0x33FA6F76),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}

import 'package:flutter/material.dart';

class SpyBackground extends StatelessWidget {
  final Widget child;
  const SpyBackground({super.key, required this.child});

  static const _background = Color(0xFF0D1117);
  static const _surface = Color(0xFF161B22);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_background, _surface.withValues(alpha: 0.85), _background],
        ),
      ),
      child: child,
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';

class AppGlassCard extends StatelessWidget {
  final Widget child;

  const AppGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: const Color(0xFF1E2233).withOpacity(0.7),
            border: Border.all(color: Colors.white24, width: 0.5),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: child,
        ),
      ),
    );
  }
}

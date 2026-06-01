import 'dart:ui';
import 'package:flutter/material.dart';

class AppGlassCard extends StatelessWidget {
  final Widget child;

  const AppGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // Lower blur to keep background stars/lines visible
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.02), // Highly transparent
                Colors.white.withOpacity(0.0),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.12), // Clean defining edge
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: -3,
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: child,
        ),
      ),
    );
  }
}

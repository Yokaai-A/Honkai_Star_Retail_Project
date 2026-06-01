import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AppActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFFD4B375)
              : Colors.transparent,
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFD4B375), width: 1.5),
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: isPrimary ? 4 : 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

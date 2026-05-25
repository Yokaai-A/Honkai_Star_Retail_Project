import 'package:flutter/material.dart';
import 'package:honkai_star_retail_app/presentation/constants/images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: Image.asset(AppImages.primaryLogo, width: 320)),
      ),
    );
  }
}

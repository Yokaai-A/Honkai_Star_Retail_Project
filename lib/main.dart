import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _appRouter = AppRouter().router;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Honkai Star Retail',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: _appRouter,
    );
  }
}

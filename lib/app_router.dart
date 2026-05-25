import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/presentation/pages/auth/login_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/auth/splash_screen.dart';

class AppRouter {
  final router = GoRouter(
    routes: [
      // Authentication Routes
      GoRoute(path: 'splash', builder: (context, state) => SplashScreen()),
      GoRoute(path: 'login', builder: (context, state) => LoginScreen()),
      // User Routes
      GoRoute(path: 'userCatalog'),
      GoRoute(path: 'resourceDetail'),
      GoRoute(path: 'checkout'),
      // Admin Routes
      GoRoute(path: 'adminDashboard'),
      GoRoute(path: 'adminEditor'),
    ],
  );
}

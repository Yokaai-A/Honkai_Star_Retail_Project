import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/presentation/pages/admin/dashboard_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/admin/editor_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/auth/login_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/auth/splash_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/checkout_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/resource_detail_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/user_catalog_screen.dart';

class AppRouter {
  final router = GoRouter(
    routes: [
      // ! Authentication Routes
      GoRoute(path: 'splash', builder: (context, state) => SplashScreen()),
      GoRoute(path: 'login', builder: (context, state) => LoginScreen()),
      // ? User Routes
      GoRoute(
        path: 'userCatalog',
        builder: (context, state) => UserCatalogScreen(),
      ),
      GoRoute(
        path: 'resourceDetail',
        builder: (context, state) => ResourceDetailScreen(),
      ),
      GoRoute(path: 'checkout', builder: (context, state) => CheckoutScreen()),
      //  Admin Routes
      GoRoute(
        path: 'adminDashboard',
        builder: (context, state) => DashboardScreen(),
      ),
      GoRoute(path: 'adminEditor', builder: (context, state) => EditorScreen()),
    ],
  );
}

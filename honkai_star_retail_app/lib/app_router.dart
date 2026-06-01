import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/core/router/router_refresh_stream.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:honkai_star_retail_app/presentation/pages/admin/dashboard_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/admin/editor_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/auth/login_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/auth/register_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/auth/splash_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/checkout_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/resource_detail_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/user_catalog_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/profile_screen.dart';
import 'package:honkai_star_retail_app/presentation/pages/warp_mission_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final currentPath = state.uri.path;

      final isSplashRoute = currentPath == '/splash';
      final isLoginRoute = currentPath == '/login';
      final isRegisterRoute = currentPath == '/register';
      final isAdminRoute = currentPath.startsWith('/admin');

      // 1. Initialization Guard
      if (authState is AuthInitial) {
        return isSplashRoute ? null : '/splash';
      }

      // 2. Unauthenticated Guard
      if (authState is AuthUnauthenticated || authState is AuthError) {
        return (isLoginRoute || isRegisterRoute) ? null : '/login';
      }

      // 3. Authenticated & Role Guard
      if (authState is AuthAuthenticated) {
        if (isSplashRoute || isLoginRoute || isRegisterRoute) {
          return authState.isAdmin ? '/adminDashboard' : '/userCatalog';
        }
        if (isAdminRoute && !authState.isAdmin) {
          return '/userCatalog';
        }
      }

      return null;
    },
    routes: [
      // ! Authentication Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      // ? User Routes
      GoRoute(
        path: '/userCatalog',
        builder: (context, state) => const UserCatalogScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/warpMission',
        builder: (context, state) => const WarpMissionScreen(),
      ),
      GoRoute(
        path: '/resourceDetail',
        builder: (context, state) {
          final item = state.extra as Map<String, dynamic>?;
          return ResourceDetailScreen(item: item);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final item = state.extra as Map<String, dynamic>?;
          return CheckoutScreen(item: item);
        },
      ),
      //  Admin Routes
      GoRoute(
        path: '/adminDashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/adminEditor',
        builder: (context, state) => const EditorScreen(),
      ),
    ],
  );
}

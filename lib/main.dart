import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honkai_star_retail_app/app_router.dart';
import 'package:honkai_star_retail_app/firebase_options.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _appRouter = AppRouter(_authBloc);

    // CRITICAL: Fire initialization event
    _authBloc.add(AuthInitializeEvent());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc, // Inject BLoC to the widget tree
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Honkai Star Retail',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF0B0D17),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            surface: Color(0xFF1E2233),
          ),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.router,
      ),
    );
  }
}

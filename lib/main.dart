import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honkai_star_retail_app/app_router.dart';
import 'package:honkai_star_retail_app/firebase_options.dart';
import 'package:honkai_star_retail_app/injection.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await injectDependency();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Resolve dependencies directly from GetIt during initialization
  late final AuthBloc _authBloc = di<AuthBloc>();
  late final AppRouter _appRouter = di<AppRouter>();

  @override
  void initState() {
    super.initState();
    _authBloc.add(AuthInitializeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
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

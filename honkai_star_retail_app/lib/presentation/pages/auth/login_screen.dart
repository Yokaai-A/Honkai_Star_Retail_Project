import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:honkai_star_retail_app/presentation/widgets/action_button.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';
import 'package:honkai_star_retail_app/presentation/widgets/textfield.dart';
import 'package:honkai_star_retail_app/presentation/widgets/constellation_background.dart';

// Adjust this import path to match your actual project structure

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _handleLogin() {
    // Executes the 3 data validations required by the rubric
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    // Dispatch the BLoC event instead of handling state locally
    context.read<AuthBloc>().add(
      AuthLoginEvent(
        _usernameController.text,
        _passwordController.text,
        AuthLoginType.regular,
      ),
    );
  }

  void _handleGoogleLogin() {
    context.read<AuthBloc>().add(AuthLoginEvent('', '', AuthLoginType.google));
  }

  void _handleReload() {
    if (_rotationController.isAnimating) return;

    // Trigger the rotating animation
    _rotationController.forward(from: 0.0);

    // Reset Form & Controllers
    _usernameController.clear();
    _passwordController.clear();
    _formKey.currentState?.reset();

    // Re-initialize Auth BLoC
    context.read<AuthBloc>().add(AuthInitializeEvent());

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Aether Link Refreshed',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD4B375),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E2233),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.rajdhani()),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return ConstellationBackground(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: AppGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _handleReload,
                              child: RotationTransition(
                                turns: Tween(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _rotationController,
                                    curve: Curves.easeInOutBack,
                                  ),
                                ),
                                child: Tooltip(
                                  message: 'Tap to reload',
                                  child: Image.asset(
                                    'assets/images/primary_logo.png',
                                    height: 72,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.refresh,
                                        size: 72,
                                        color: Color(0xFFD4B375),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome back !',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: _usernameController,
                            hintText: 'Trailblazer ID / Username',
                            enabled: !isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ID cannot be empty'; // Validation 1
                              }
                              if (value.contains(' ')) {
                                return 'ID cannot contain spaces'; // Validation 2
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            obscureText: true,
                            enabled: !isLoading,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be >= 6 characters'; // Validation 3
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFD4B375),
                                  ),
                                )
                              : AppActionButton(
                                  label: 'Login',
                                  onPressed: _handleLogin,
                                  isPrimary: true,
                                ),

                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Colors.white24),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  'External Auth',
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: Colors.white24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppActionButton(
                            label: 'Login with Google',
                            onPressed: isLoading
                                ? () {}
                                : () {
                                    _handleGoogleLogin();
                                  },
                            isPrimary: false,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        context.go('/register');
                                      },
                                child: Text(
                                  "Register here",
                                  style: GoogleFonts.rajdhani(
                                    color: const Color(0xFFD4B375),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

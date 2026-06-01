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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    // Dispatch register event to BLoC
    context.read<AuthBloc>().add(
      AuthRegisterEvent(
        _usernameController.text.trim(),
        _passwordController.text,
      ),
    );
  }

  void _handleReload() {
    if (_rotationController.isAnimating) return;

    // Trigger the rotating animation
    _rotationController.forward(from: 0.0);

    // Reset Form & Controllers
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _formKey.currentState?.reset();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Registration Terminal Reset',
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
    _confirmPasswordController.dispose();
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
          } else if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Aether Access Granted! Please Login.',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFD4B375),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: const Color(0xFF1E2233),
                duration: const Duration(seconds: 3),
              ),
            );
            // Navigate back to Login Screen
            context.go('/login');
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
                            'CREATE ACCOUNT',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              fontSize: 28,
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
                              if (value == null || value.trim().isEmpty) {
                                return 'ID cannot be empty';
                              }
                              if (value.contains(' ')) {
                                return 'ID cannot contain spaces';
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
                                return 'Password must be >= 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm Password',
                            obscureText: true,
                            enabled: !isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm Password cannot be empty';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
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
                                  label: 'Register',
                                  onPressed: _handleRegister,
                                  isPrimary: true,
                                ),

                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        context.go('/login');
                                      },
                                child: Text(
                                  "Login here",
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

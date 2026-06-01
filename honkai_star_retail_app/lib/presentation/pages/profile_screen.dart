import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:honkai_star_retail_app/presentation/controllers/profile_controller.dart';
import 'package:honkai_star_retail_app/presentation/widgets/constellation_background.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:honkai_star_retail_app/presentation/widgets/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController.text = ProfileController.instance.usernameNotifier.value;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 350,
        maxHeight: 350,
        imageQuality: 70,
      );
      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        final String base64String = base64Encode(bytes);
        await ProfileController.instance.setAvatar('data:image/png;base64,$base64String');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PORTRAIT FILE SYNCHRONIZED',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFD4B375),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF161F32),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'UPLOAD ERROR: $e',
              style: GoogleFonts.rajdhani(color: Colors.redAccent),
            ),
            backgroundColor: const Color(0xFF161F32),
          ),
        );
      }
    }
  }

  void _saveProfileChanges() {
    if (!_formKey.currentState!.validate()) return;
    
    final newUsername = _usernameController.text.trim();
    ProfileController.instance.setUsername(newUsername);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PROFILE SYNCHRONIZED',
          style: GoogleFonts.rajdhani(color: const Color(0xFFD4B375), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF161F32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final bool isAdmin = authState is AuthAuthenticated ? authState.isAdmin : false;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220).withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD4B375), size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/userCatalog'),
        ),
        title: Text(
          'TRAILBLAZER PROFILE',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD4B375),
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFD4B375).withOpacity(0.3),
            height: 1.0,
          ),
        ),
      ),
      body: ConstellationBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profile Stats Summary Card (No level information)
                  AppGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Large Avatar with Gold Border
                          ValueListenableBuilder<String?>(
                            valueListenable: ProfileController.instance.avatarUrlNotifier,
                            builder: (context, avatarUrl, _) {
                              return Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFD4B375), width: 2.0),
                                  color: const Color(0xFF161F32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4B375).withOpacity(0.15),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(45),
                                  child: ProfileController.instance.buildAvatarWidget(avatarUrl, 90),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String>(
                            valueListenable: ProfileController.instance.usernameNotifier,
                            builder: (context, username, _) {
                              return Text(
                                username.toUpperCase(),
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  letterSpacing: 1.5,
                                ),
                              );
                            },
                          ),
                          Text(
                            'UID: 802619420',
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 16),
                          
                          // User Stats (No level info)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ValueListenableBuilder<int>(
                                valueListenable: ProfileController.instance.warpsInitiatedNotifier,
                                builder: (context, warpsCount, _) {
                                  return _buildProfileStat(
                                    'WARPS INITIATED',
                                    '$warpsCount Times',
                                    const Color(0xFF00FFCC),
                                  );
                                },
                              ),
                              _buildProfileStat('AETHER LINK', 'ACTIVE', Colors.greenAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Profile Details Forms (Username & Image File picker)
                  Text(
                    'EDIT TRAILBLAZER DATA',
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFFD4B375),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Username', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _usernameController,
                            style: GoogleFonts.rajdhani(color: Colors.white),
                            decoration: _buildInputDecoration(hint: 'Trailblazer'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                  return 'Username cannot be empty';
                              }
                              if (val.trim().length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          Text('Quantum Portrait file', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF00FFCC),
                                    side: const BorderSide(color: Color(0xFF00FFCC), width: 0.8),
                                    shape: const BeveledRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                                  label: Text(
                                    'UPLOAD PORTRAIT FILE',
                                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                  onPressed: _uploadImage,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: Colors.white70,
                                  shape: const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () {
                                  ProfileController.instance.clearAvatar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'AVATAR RESET',
                                        style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: const Color(0xFF161F32),
                                    ),
                                  );
                                },
                                child: Text(
                                  'CLEAR',
                                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 16),
                          
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4B375),
                              foregroundColor: const Color(0xFF0B1220),
                              shape: const BeveledRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shadowColor: const Color(0xFFD4B375).withOpacity(0.35),
                              elevation: 6,
                            ),
                            onPressed: _saveProfileChanges,
                            child: Text(
                              'SAVE DATA CHANGES',
                              style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828).withOpacity(0.8),
                              foregroundColor: Colors.white,
                              shape: const BeveledRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.redAccent, width: 0.5),
                            ),
                            icon: const Icon(Icons.logout),
                            label: Text(
                              'DISCONNECT LINK',
                              style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(AuthLogoutEvent());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 2,
        isAdmin: isAdmin,
        onTap: (index) {
          if (index == 0) {
            context.go('/userCatalog');
          } else if (index == 1) {
            context.go('/warpMission');
          } else if (index == 2) {
            // Already on profile
          } else if (index == 3 && isAdmin) {
            context.go('/adminDashboard');
          }
        },
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.rajdhani(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
      filled: true,
      fillColor: Colors.black26,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD4B375)),
        borderRadius: BorderRadius.circular(6),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE53935)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE53935)),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

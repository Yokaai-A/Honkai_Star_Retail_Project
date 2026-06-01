import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController {
  static final ProfileController instance = ProfileController._internal();
  ProfileController._internal();

  final ValueNotifier<String?> avatarUrlNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String> usernameNotifier = ValueNotifier<String>('Trailblazer');
  final ValueNotifier<double> jadesNotifier = ValueNotifier<double>(12850.0);
  final ValueNotifier<double> creditsNotifier = ValueNotifier<double>(2500000.0);
  final ValueNotifier<int> warpsInitiatedNotifier = ValueNotifier<int>(0);

  Future<void> loadProfileData(String defaultName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      avatarUrlNotifier.value = prefs.getString('hsr_avatar_url');
      usernameNotifier.value = prefs.getString('hsr_username') ?? defaultName;
      jadesNotifier.value = prefs.getDouble('hsr_jades') ?? 12850.0;
      creditsNotifier.value = prefs.getDouble('hsr_credits') ?? 2500000.0;
      warpsInitiatedNotifier.value = prefs.getInt('hsr_warps_initiated') ?? 0;
    } catch (_) {
      usernameNotifier.value = defaultName;
    }
  }

  Future<void> updateBalances({double? jades, double? credits}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (jades != null) {
        jadesNotifier.value = jades;
        await prefs.setDouble('hsr_jades', jades);
      }
      if (credits != null) {
        creditsNotifier.value = credits;
        await prefs.setDouble('hsr_credits', credits);
      }
    } catch (_) {}
  }

  Future<void> incrementWarpsInitiated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newValue = warpsInitiatedNotifier.value + 1;
      warpsInitiatedNotifier.value = newValue;
      await prefs.setInt('hsr_warps_initiated', newValue);
    } catch (_) {}
  }

  Future<void> setAvatar(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hsr_avatar_url', url);
      avatarUrlNotifier.value = url;
    } catch (_) {
      avatarUrlNotifier.value = url;
    }
  }

  Future<void> setUsername(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hsr_username', name);
      usernameNotifier.value = name;
    } catch (_) {
      usernameNotifier.value = name;
    }
  }

  Future<void> clearAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hsr_avatar_url');
      avatarUrlNotifier.value = null;
    } catch (_) {
      avatarUrlNotifier.value = null;
    }
  }

  Widget buildAvatarWidget(String? avatarUrl, double size, {IconData defaultIcon = Icons.person}) {
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    if (!hasAvatar) {
      return Icon(defaultIcon, color: const Color(0xFFD4B375), size: size * 0.5);
    }
    
    if (avatarUrl.startsWith('data:image')) {
      try {
        final base64Data = avatarUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (c, o, s) => Icon(defaultIcon, color: const Color(0xFFD4B375), size: size * 0.5),
        );
      } catch (_) {
        return Icon(defaultIcon, color: const Color(0xFFD4B375), size: size * 0.5);
      }
    }
    
    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (c, o, s) => Icon(defaultIcon, color: const Color(0xFFD4B375), size: size * 0.5),
    );
  }
}

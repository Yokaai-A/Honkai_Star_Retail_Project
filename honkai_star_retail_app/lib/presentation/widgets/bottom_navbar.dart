import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isAdmin;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.storefront, 'label': 'Manifest'},
      {'icon': Icons.auto_awesome, 'label': 'Warp'},
      {'icon': Icons.account_circle_outlined, 'label': 'Profile'},
      if (isAdmin) {'icon': Icons.admin_panel_settings_outlined, 'label': 'Admin'},
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double navbarWidth = screenWidth > 532 ? 500 : (screenWidth - 32.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: navbarWidth,
              child: AppGlassCard(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isSelected = currentIndex == index;
                      final Color color = isSelected ? const Color(0xFFD4B375) : Colors.white60;
      
                      return Expanded(
                        child: InkWell(
                          onTap: () => onTap(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: color,
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                (item['label'] as String).toUpperCase(),
                                style: GoogleFonts.rajdhani(
                                  color: color,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

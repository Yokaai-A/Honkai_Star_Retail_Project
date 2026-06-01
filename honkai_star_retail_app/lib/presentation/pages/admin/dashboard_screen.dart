import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/core/services/api_service.dart';
import 'package:honkai_star_retail_app/presentation/widgets/constellation_background.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:honkai_star_retail_app/presentation/widgets/bottom_navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  final List<String> _systemLogs = [
    'SYSTEM [06:12:04] - Aether link initialized successfully on port 3000.',
    'DATABASE [06:14:22] - MySQL connection pool established.',
    'AUTH [06:15:30] - JWT service active. Token expiry: 1d.',
    'WARP [06:30:11] - Warp manifest connection established. Client synchronizing.',
    'SECURITY [07:05:00] - Bearer token verification operating at 100%.',
    'CATALOG [07:12:45] - REST API synced: /api/resources active.',
  ];

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.instance.getStats();
  }

  void _addMockLog() {
    setState(() {
      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      _systemLogs.insert(
        0,
        'USERLOG [$timeStr] - Admin requested manual system check.',
      );
      // Reload stats on diagnostic run
      _statsFuture = ApiService.instance.getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final bool isAdmin =
        authState is AuthAuthenticated ? authState.isAdmin : true;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220).withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFD4B375),
            size: 20,
          ),
          onPressed: () => context.go('/userCatalog'),
        ),
        title: Text(
          'EXPRESS ADMIN TERMINAL',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. System Telemetry Metrics Grid – data nyata dari server
                Text(
                  'SYSTEM METRICS',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFD4B375),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<Map<String, dynamic>>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    // Parse values (fallback ke '--' jika loading/error)
                    final String totalUsers = snapshot.hasData
                        ? '${snapshot.data!['totalUsers']} Members'
                        : snapshot.hasError
                            ? 'Offline'
                            : '...';
                    final String totalResources = snapshot.hasData
                        ? '${snapshot.data!['totalResources']} Items'
                        : snapshot.hasError
                            ? 'Offline'
                            : '...';
                    final String totalTransactions = snapshot.hasData
                        ? '${snapshot.data!['totalTransactions']} Warps'
                        : snapshot.hasError
                            ? 'Offline'
                            : '...';

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'ACTIVE TRAILBLAZERS',
                                value: totalUsers,
                                icon: Icons.people_outline,
                                color: const Color(0xFF00FFCC),
                                isLoading: snapshot.connectionState ==
                                    ConnectionState.waiting,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'CATALOG RESOURCES',
                                value: totalResources,
                                icon: Icons.inventory_2_outlined,
                                color: const Color(0xFFD4B375),
                                isLoading: snapshot.connectionState ==
                                    ConnectionState.waiting,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'WARP TRANSACTIONS',
                                value: totalTransactions,
                                icon: Icons.toll,
                                color: const Color(0xFF00FFCC),
                                isLoading: snapshot.connectionState ==
                                    ConnectionState.waiting,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'SERVER STATUS',
                                value: snapshot.hasError ? 'OFFLINE' : 'ONLINE',
                                icon: snapshot.hasError
                                    ? Icons.cloud_off
                                    : Icons.cloud_done_outlined,
                                color: snapshot.hasError
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF4CAF50),
                                isLoading: snapshot.connectionState ==
                                    ConnectionState.waiting,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 2. Terminal Log Output Screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SYSTEM LOG MONITOR',
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFFD4B375),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                    InkWell(
                      onTap: _addMockLog,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00FFCC).withOpacity(0.4),
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFF00FFCC).withOpacity(0.05),
                        ),
                        child: Text(
                          'RUN DIAGNOSTIC',
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFF00FFCC),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppGlassCard(
                  child: Container(
                    height: 180,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black45,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _systemLogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            _systemLogs[index],
                            style: GoogleFonts.shareTechMono(
                              color: Colors.greenAccent,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Admin Shortcuts & Actions
                Text(
                  'QUICK INTERFACES',
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
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF161F32),
                            foregroundColor: const Color(0xFFD4B375),
                            side: const BorderSide(
                              color: Color(0xFFD4B375),
                              width: 0.8,
                            ),
                            shape: const BeveledRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.edit_note, size: 20),
                          label: Text(
                            'LAUNCH RESOURCE SYNTHESIZER',
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          onPressed: () => context.push('/adminEditor'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF161F32),
                            foregroundColor: const Color(0xFF00FFCC),
                            side: const BorderSide(
                              color: Color(0xFF00FFCC),
                              width: 0.8,
                            ),
                            shape: const BeveledRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                          ),
                          label: Text(
                            'RETURN TO CATALOG TERMINAL',
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          onPressed: () => context.go('/userCatalog'),
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
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 3,
        isAdmin: isAdmin,
        onTap: (index) {
          if (index == 0) {
            context.go('/userCatalog');
          } else if (index == 1) {
            context.go('/warpMission');
          } else if (index == 2) {
            context.go('/profile');
          } else if (index == 3) {
            // Already on admin dashboard
          }
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return AppGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: color,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.rajdhani(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

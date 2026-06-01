import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:honkai_star_retail_app/presentation/widgets/constellation_background.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';
import 'package:honkai_star_retail_app/presentation/widgets/bottom_navbar.dart';
import 'package:honkai_star_retail_app/presentation/controllers/profile_controller.dart';

class WarpMissionScreen extends StatefulWidget {
  const WarpMissionScreen({super.key});

  @override
  State<WarpMissionScreen> createState() => _WarpMissionScreenState();
}

class _WarpMissionScreenState extends State<WarpMissionScreen> with SingleTickerProviderStateMixin {
  bool _isDispatching = false;
  double _progress = 0.0;
  Timer? _timer;
  int _secondsRemaining = 5;
  
  // Reward results
  bool _showReward = false;
  String _rewardType = 'JADE'; // JADE or CREDIT
  double _rewardAmount = 0.0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startMission() {
    if (_isDispatching) return;

    setState(() {
      _isDispatching = true;
      _progress = 0.0;
      _secondsRemaining = 5;
      _showReward = false;
    });

    const int steps = 50; // Update every 100ms
    int currentStep = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentStep++;
      setState(() {
        _progress = currentStep / steps;
        _secondsRemaining = 5 - (currentStep ~/ 10);
      });

      if (currentStep >= steps) {
        timer.cancel();
        _completeMission();
      }
    });
  }

  void _completeMission() {
    final random = Random();
    // 50% chance of Jade, 50% chance of Credit
    final isJadeReward = random.nextBool();
    
    ProfileController.instance.incrementWarpsInitiated();

    setState(() {
      _isDispatching = false;
      _showReward = true;
      if (isJadeReward) {
        _rewardType = 'JADE';
        // Random Jade amount between 80 and 200 (intervals of 10)
        _rewardAmount = (8 + random.nextInt(13)) * 10.0;
      } else {
        _rewardType = 'CREDIT';
        // Random Credit amount between 15000 and 50000 (intervals of 5000)
        _rewardAmount = (3 + random.nextInt(8)) * 5000.0;
      }
    });
  }

  void _claimReward() {
    if (!_showReward) return;

    final currentJades = ProfileController.instance.jadesNotifier.value;
    final currentCredits = ProfileController.instance.creditsNotifier.value;

    if (_rewardType == 'JADE') {
      ProfileController.instance.updateBalances(jades: currentJades + _rewardAmount);
    } else {
      ProfileController.instance.updateBalances(credits: currentCredits + _rewardAmount);
    }

    setState(() {
      _showReward = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF161F32),
        content: Text(
          'REWARD CLAIMED SUCCESSFULLY!',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD4B375),
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    bool isAdmin = false;
    if (authState is AuthAuthenticated) {
      isAdmin = authState.isAdmin;
    }

    final Color primaryColor = const Color(0xFFD4B375); // Stellar Gold

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220).withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD4B375), size: 20),
          onPressed: () => context.go('/userCatalog'),
        ),
        title: Text(
          'MISSION CONTROL',
          style: GoogleFonts.rajdhani(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: primaryColor.withOpacity(0.3),
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
                const SizedBox(height: 10),
                
                // Mission Details Card
                AppGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Mission Header Badge with pulse animation
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isDispatching
                                    ? Colors.redAccent.withOpacity(0.15 + 0.1 * _pulseController.value)
                                    : primaryColor.withOpacity(0.1 + 0.1 * _pulseController.value),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isDispatching ? Colors.redAccent : primaryColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isDispatching ? Icons.radar : Icons.auto_awesome,
                                    color: _isDispatching ? Colors.redAccent : primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isDispatching
                                        ? 'MISSION IN PROGRESS'
                                        : 'AVAILABLE COMMISSION',
                                    style: GoogleFonts.rajdhani(
                                      color: _isDispatching ? Colors.redAccent : primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Mission Title
                        Text(
                          'WARP PATH DISCOVERY',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        Text(
                          'Deploy your trailblazing coordinates to explore unharvested path nodes in the Simulated Universe. Nodes are known to contain traces of Stellar Jade or Credit crystals.',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Timer Indicator or Button
                        if (_isDispatching) ...[
                          // Circular progress with seconds text in center
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4B375)),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_secondsRemaining}S',
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'REMAINING',
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'TRANSMITTING PATH-DATA COORDINATES...',
                            style: GoogleFonts.rajdhani(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ] else if (_showReward) ...[
                          // Reward Result layout
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161F32).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'MISSION COMPLETED!',
                                  style: GoogleFonts.rajdhani(
                                    color: const Color(0xFF00FFCC),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Reward Icon
                                Image.asset(
                                  _rewardType == 'JADE'
                                      ? 'assets/images/stellarJade.png'
                                      : 'assets/images/credits.png',
                                  width: 64,
                                  height: 64,
                                ),
                                const SizedBox(height: 12),
                                // Reward Value
                                Text(
                                  '+${_formatAmount(_rewardAmount)} ${_rewardType == 'JADE' ? 'STELLAR JADE' : 'CREDITS'}',
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Claim Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: const Color(0xFF0B1220),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _claimReward,
                                    child: Text(
                                      'CLAIM REWARD',
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Dispatch controls
                          Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.rocket_launch_outlined,
                              color: primaryColor.withOpacity(0.4),
                              size: 72,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: const Color(0xFF0B1220),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
                                ),
                                elevation: 8,
                                shadowColor: primaryColor.withOpacity(0.3),
                              ),
                              onPressed: _startMission,
                              child: Text(
                                'DISPATCH TRAILBLAZER',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Mission specifications card
                AppGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MISSION SPECIFICATIONS',
                          style: GoogleFonts.rajdhani(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSpecRow('OBJECTIVE', 'HARVEST STRATEGIC ENERGY NODES'),
                        _buildSpecRow('DURATION', '5.0 SECONDS'),
                        _buildSpecRow('RISK LEVEL', 'MINIMAL (SAFETY PROTOCOLS ACTIVE)'),
                        _buildSpecRow('POTENTIAL REWARDS', 'STELLAR JADE / CREDITS (RANDOMIZED)'),
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
        currentIndex: 1,
        isAdmin: isAdmin,
        onTap: (index) {
          if (index == 0) {
            context.go('/userCatalog');
          } else if (index == 1) {
            // Already on Warp Mission screen
          } else if (index == 2) {
            context.go('/profile');
          } else if (index == 3 && isAdmin) {
            context.go('/adminDashboard');
          }
        },
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.rajdhani(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

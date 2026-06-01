import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/presentation/widgets/constellation_background.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';
import 'package:honkai_star_retail_app/presentation/controllers/profile_controller.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? item; // This is actually the state.extra map containing 'item' and 'quantity'
  const CheckoutScreen({super.key, this.item});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // Mock User Balances
  double _userJades = 12850.0;
  double _userCredits = 2500000.0; // 2.5M

  @override
  void initState() {
    super.initState();
    _userJades = ProfileController.instance.jadesNotifier.value;
    _userCredits = ProfileController.instance.creditsNotifier.value;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _executePurchase(double cost, bool isJade, String itemName, int quantity) {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate network delay for warp transaction processing
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        // Deduct balance
        if (isJade) {
          _userJades -= cost;
          ProfileController.instance.updateBalances(jades: _userJades);
        } else {
          _userCredits -= cost;
          ProfileController.instance.updateBalances(credits: _userCredits);
        }
      });

      _showSuccessDialog(itemName, quantity);
    });
  }

  void _showSuccessDialog(String itemName, int quantity) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AppGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00FFCC), width: 2),
                      color: const Color(0xFF0B1220),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF00FFCC),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'WARP COMPLETED',
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFF00FFCC),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The Astral Manifest has successfully dispatched your order.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$quantity x ${itemName.toUpperCase()}',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Delivered to Astral Express Cabin Inventory',
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFFD4B375),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4B375),
                      foregroundColor: const Color(0xFF0B1220),
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Dismiss Dialog
                      context.go('/userCatalog');  // Return to Catalog
                    },
                    child: Text(
                      'RETURN TO TERMINAL',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract the item map and quantity
    final Map<String, dynamic> extra = widget.item ?? {};
    final Map<String, dynamic>? item = extra['item'] as Map<String, dynamic>?;
    final int quantity = extra['quantity'] as int? ?? 1;

    if (item == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Center(
          child: Text(
            'TRANSACTION MANIFEST VOID',
            style: GoogleFonts.rajdhani(color: Colors.redAccent, fontSize: 18),
          ),
        ),
      );
    }

    final bool isJade = item['priceType'] == 'JADE';
    final Color themeColor = isJade ? const Color(0xFF00FFCC) : const Color(0xFFD4B375);
    final double basePrice = (item['price'] as num).toDouble();
    final double totalCost = basePrice * quantity;

    // Check balances
    final double currentBalance = isJade ? _userJades : _userCredits;
    final double remainingBalance = currentBalance - totalCost;
    final bool hasInsufficientFunds = remainingBalance < 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220).withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD4B375), size: 20),
          onPressed: _isProcessing ? null : () => context.pop(),
        ),
        title: Text(
          'TRANSACTION LEDGER',
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
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Order Manifest Card
                      Text(
                        'MANIFEST DESPATCH',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'].toString().toUpperCase(),
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          item['type'].toString().toUpperCase(),
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white38,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'x$quantity',
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 16),
                              
                              // Pricing Breakdown details
                              _buildManifestRow(
                                label: 'UNIT VALUE',
                                value: _formatPrice(basePrice),
                                color: themeColor,
                                isJade: isJade,
                              ),
                              const SizedBox(height: 12),
                              _buildManifestRow(
                                label: 'TRANSACTION TOTAL',
                                value: _formatPrice(totalCost),
                                color: themeColor,
                                isJade: isJade,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Balances Assessment Card
                      Text(
                        'BALANCES ASSESSMENT',
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
                            children: [
                              _buildBalanceRow(
                                label: 'CURRENT BALANCE',
                                value: _formatPrice(currentBalance),
                                isJade: isJade,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              _buildBalanceRow(
                                label: 'ESTIMATED REMAINING',
                                value: _formatPrice(remainingBalance),
                                isJade: isJade,
                                color: hasInsufficientFunds ? const Color(0xFFE53935) : const Color(0xFF00FFCC),
                              ),
                              if (hasInsufficientFunds) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935).withOpacity(0.1),
                                    border: Border.all(color: const Color(0xFFE53935).withOpacity(0.4)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'INSUFFICIENT FUNDS FOR WARP TRANSMISSION',
                                          style: GoogleFonts.rajdhani(
                                            color: const Color(0xFFE53935),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Security verification Pin Card
                      if (!hasInsufficientFunds) ...[
                        Text(
                          'SECURITY PIN AUTHENTICATION',
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
                                Text(
                                  'Enter transaction authentication pin (e.g. 123456)',
                                  style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _pinController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  maxLength: 6,
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 8.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: Colors.black26,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.white24),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: themeColor),
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
                                    hintText: '••••••',
                                    hintStyle: GoogleFonts.rajdhani(
                                      color: Colors.white24,
                                      fontSize: 18,
                                      letterSpacing: 8.0,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Authentication PIN required';
                                    }
                                    if (value.length < 4) {
                                      return 'PIN must be at least 4 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Action Authorize Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: const Color(0xFF0B1220),
                            shape: const BeveledRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shadowColor: themeColor.withOpacity(0.4),
                            elevation: 8,
                          ),
                          onPressed: () => _executePurchase(totalCost, isJade, item['name'], quantity),
                          child: Text(
                            'AUTHORIZE WARP PURCHASE',
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 30),
                        // Return/Cancel button since funds are insufficient
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white54,
                            shape: const BeveledRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => context.pop(),
                          child: Text(
                            'ABORT TRANSMISSION',
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Processing overlay indicator
              if (_isProcessing)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black45,
                      child: Center(
                        child: AppGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: themeColor),
                                const SizedBox(height: 20),
                                Text(
                                  'AUTHENTICATING WARP LINK...',
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManifestRow({
    required String label,
    required String value,
    required Color color,
    required bool isJade,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Colors.white54,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isJade
                ? Image.asset(
                    'assets/images/stellarJade.png',
                    width: isBold ? 16 : 14,
                    height: isBold ? 16 : 14,
                  )
                : Image.asset(
                    'assets/images/credits.png',
                    width: isBold ? 16 : 14,
                    height: isBold ? 16 : 14,
                  ),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.rajdhani(
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: isBold ? 18 : 15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceRow({
    required String label,
    required String value,
    required bool isJade,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Colors.white54,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isJade
                ? Opacity(
                    opacity: 0.8,
                    child: Image.asset(
                      'assets/images/stellarJade.png',
                      width: 14,
                      height: 14,
                    ),
                  )
                : Opacity(
                    opacity: 0.8,
                    child: Image.asset(
                      'assets/images/credits.png',
                      width: 14,
                      height: 14,
                    ),
                  ),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.rajdhani(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price == price.toInt()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(0);
  }
}

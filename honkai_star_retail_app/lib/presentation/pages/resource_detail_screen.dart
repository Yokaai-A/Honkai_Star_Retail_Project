import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/presentation/widgets/constellation_background.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';

class ResourceDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const ResourceDetailScreen({super.key, this.item});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Default quantity to 0 if out of stock
    if (widget.item != null && widget.item!['stock'] <= 0) {
      _quantity = 0;
    }
  }

  void _increment() {
    final maxStock = widget.item?['stock'] ?? 0;
    if (_quantity < maxStock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  String _getSciFiDescription(String name) {
    switch (name.toUpperCase()) {
      case 'BEFORE DAWN':
        return 'A high-frequency Light Cone that stores the combat memory of the Divine Foresight. Greatly increases the wearer\'s Critical Damage and follow-up skill output. Powered by path energy.';
      case 'PERFECT TIMING':
        return 'A Light Cone recording a frozen moment. It portrays Luocha treating a patient. Increases the wearer\'s Effect Resistance and outgoing healing capacity based on their mental focus.';
      case 'STAR RAIL PASS':
        return 'A ticket required to warp aboard the Astral Express. Emits a subtle cosmic hum, containing the coordinates of distant stellar systems.';
      case 'STELLAR JADE':
        return 'A cluster of condensed celestial energy. The primary currency used to acquire Warp Passes. Highly valued by members of the Express and Interastral Peace Corporation.';
      case 'TRACKS OF DESTINY':
        return 'A rare catalyst obtained from the memories of the universe. Crucial for tracing the path of Destinies and leveling up high-tier combat abilities.';
      default:
        return 'A rare interastral resource of unknown origin. Useful for trading and customizing equipment aboard the Astral Express.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Center(
          child: Text(
            'MANIFEST DATA CORRUPTED: NO RESOURCE SELECT',
            style: GoogleFonts.rajdhani(color: Colors.redAccent, fontSize: 18),
          ),
        ),
      );
    }

    final item = widget.item!;
    final bool isOutOfStock = item['stock'] <= 0;
    final bool isJade = item['priceType'] == 'JADE';
    final Color themeColor = isJade ? const Color(0xFF00FFCC) : const Color(0xFFD4B375);
    final String priceStr = isJade ? 'Stellar Jade' : 'Credits';

    final double basePrice = (item['price'] as num).toDouble();
    final double totalPrice = basePrice * _quantity;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220).withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD4B375), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'MANIFEST SPECIFICATIONS',
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Interactive floating product card details
                AppGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Header: Stock badge & Item Title/Type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontSize: 24,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    item['type'].toString().toUpperCase(),
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white54,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Stock Badge
                            Transform(
                              transform: Matrix4.skewX(-0.15),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  color: isOutOfStock ? const Color(0xFFE53935) : const Color(0xFFD4B375),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Transform(
                                  transform: Matrix4.skewX(0.15),
                                  child: Text(
                                    isOutOfStock ? 'DEPLETED' : 'Stock: ${item['stock']}',
                                    style: GoogleFonts.rajdhani(
                                      color: isOutOfStock ? Colors.white : const Color(0xFF0B1220),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Center asset placeholder with dotted border
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: item['image'] != null && item['image'].toString().isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: themeColor.withOpacity(0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      item['image'].toString(),
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, st) => const Center(
                                        child: Icon(Icons.broken_image, color: Colors.white30, size: 40),
                                      ),
                                    ),
                                  ),
                                )
                              : CustomPaint(
                                  painter: DottedBorderPainter(
                                    color: themeColor.withOpacity(0.35),
                                    strokeWidth: 1.5,
                                    gap: 6.0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.01),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          isJade
                                              ? Opacity(
                                                  opacity: 0.15,
                                                  child: Image.asset(
                                                    'assets/images/stellarJade.png',
                                                    width: 52,
                                                    height: 52,
                                                  ),
                                                )
                                              : Opacity(
                                                  opacity: 0.15,
                                                  child: Image.asset(
                                                    'assets/images/credits.png',
                                                    width: 52,
                                                    height: 52,
                                                  ),
                                                ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'PNG GRAPHIC SPACE',
                                            style: GoogleFonts.rajdhani(
                                              color: Colors.white24,
                                              fontSize: 11,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Description Section
                        Text(
                          'DATA STREAM DESCRIPTION',
                          style: GoogleFonts.rajdhani(
                            color: themeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSciFiDescription(item['name']),
                          style: GoogleFonts.rajdhani(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Transaction Controls (Quantity Selector & Pricing)
                AppGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Quantity Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ORDER QUANTITY',
                              style: GoogleFonts.rajdhani(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Row(
                              children: [
                                // Decrement Button
                                InkWell(
                                  onTap: isOutOfStock ? null : _decrement,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white24),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.remove, color: Colors.white, size: 16),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '$_quantity',
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Increment Button
                                InkWell(
                                  onTap: isOutOfStock ? null : _increment,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white24),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 16),

                        // Cost Summary Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL COST',
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  'Currency: $priceStr',
                                  style: GoogleFonts.rajdhani(
                                    color: themeColor.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                isJade
                                    ? Image.asset(
                                        'assets/images/stellarJade.png',
                                        width: 20,
                                        height: 20,
                                      )
                                    : Image.asset(
                                        'assets/images/credits.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatPrice(totalPrice),
                                  style: GoogleFonts.rajdhani(
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 3. Glowing Action Purchase Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOutOfStock ? Colors.white10 : themeColor,
                    foregroundColor: const Color(0xFF0B1220),
                    disabledBackgroundColor: Colors.white10,
                    shadowColor: themeColor.withOpacity(0.4),
                    elevation: isOutOfStock ? 0 : 8,
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isOutOfStock
                      ? null
                      : () {
                          context.push(
                            '/checkout',
                            extra: {
                              'item': item,
                              'quantity': _quantity,
                            },
                          );
                        },
                  child: Text(
                    isOutOfStock ? 'OUT OF STOCK' : 'INITIATE WARP TRANSACTION',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.toInt()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(0);
  }
}

// --- DottedBorderPainter ---
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DottedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    ));

    final Path dashPath = Path();
    double distance = 0.0;
    for (final PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gap != gap;
}

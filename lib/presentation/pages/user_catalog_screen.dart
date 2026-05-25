import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';
// TODO: Import your previously defined HsrGlassCard
// import 'package:honkai_star_retail_app/presentation/components/hsr_glass_card.dart';

class UserCatalogScreen extends StatefulWidget {
  const UserCatalogScreen({super.key});

  @override
  State<UserCatalogScreen> createState() => _UserCatalogScreenState();
}

class _UserCatalogScreenState extends State<UserCatalogScreen> {
  // Simulating an API fetch from your Node.js backend
  late Future<List<Map<String, dynamic>>> _inventoryFuture;

  @override
  void initState() {
    super.initState();
    _inventoryFuture = _fetchMockInventory();
  }

  Future<List<Map<String, dynamic>>> _fetchMockInventory() async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Network latency simulation
    return [
      {
        'id': 'RSC-001',
        'name': 'Stellar Jade',
        'type': 'Currency',
        'price': 99.99,
        'stock': 999,
        'image': 'https://placehold.co/400x400/1E2233/D4AF37/png?text=Jade',
      },
      {
        'id': 'RSC-002',
        'name': 'Star Rail Pass',
        'type': 'Ticket',
        'price': 15.00,
        'stock': 50,
        'image': 'https://placehold.co/400x400/1E2233/D4AF37/png?text=Pass',
      },
      {
        'id': 'LC-001',
        'name': 'Before Dawn',
        'type': 'Light Cone',
        'price': 120.00,
        'stock': 0, // Testing out-of-stock badge
        'image': 'https://placehold.co/400x400/1E2233/D4AF37/png?text=Dawn',
      },
      {
        'id': 'RSC-003',
        'name': 'Traveler\'s Guide',
        'type': 'Material',
        'price': 5.50,
        'stock': 1200,
        'image': 'https://placehold.co/400x400/1E2233/D4AF37/png?text=EXP',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D17),
        title: Text(
          'RETAIL MANIFEST',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () {
              // TODO: Trigger AuthBloc logout event here
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white24, height: 1.0),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _inventoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'TERMINAL ERROR: ${snapshot.error}',
                style: GoogleFonts.rajdhani(color: Colors.redAccent),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'NO RESOURCES AVAILABLE',
                style: GoogleFonts.rajdhani(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
            );
          }

          final inventory = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75, // Adjusts height vs width ratio of tiles
            ),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final item = inventory[index];
              return HsrGridTile(
                item: item,
                onTap: () {
                  // Passes the full item map to the detail screen
                  context.push('/resourceDetail', extra: item);
                },
              );
            },
          );
        },
      ),
    );
  }
}

// --- Component 4: HsrGridTile ---
class HsrGridTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const HsrGridTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = item['stock'] <= 0;

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: Opacity(
        opacity: isOutOfStock ? 0.5 : 1.0,
        // Assuming HsrGlassCard is defined elsewhere. If not, replace with a Container.
        child: AppGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upper 70%: Image and Badge
              Expanded(
                flex: 7,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(item['image'], fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: HsrStockBadge(stock: item['stock']),
                    ),
                  ],
                ),
              ),
              // Lower 30%: Metadata
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.black45, // Darker base for text contrast
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        item['name'].toString().toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['type'],
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${item['price'].toStringAsFixed(2)}',
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Component 5: HsrStockBadge ---
class HsrStockBadge extends StatelessWidget {
  final int stock;

  const HsrStockBadge({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final bool hasStock = stock > 0;
    final Color badgeColor = hasStock
        ? const Color(0xFFD4AF37)
        : Colors.redAccent;
    final String label = hasStock ? 'STOCK: $stock' : 'DEPLETED';

    return Transform(
      transform: Matrix4.skewX(-0.2), // Creates the angled HoYoverse UI look
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.9),
          border: Border.all(color: Colors.white, width: 0.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            color: hasStock ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

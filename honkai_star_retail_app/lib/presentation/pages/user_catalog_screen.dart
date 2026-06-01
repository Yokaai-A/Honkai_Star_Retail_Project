import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/core/services/api_service.dart';
import 'package:honkai_star_retail_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';
import 'package:honkai_star_retail_app/presentation/widgets/constellation_background.dart';
import 'package:honkai_star_retail_app/presentation/controllers/profile_controller.dart';
import 'package:honkai_star_retail_app/presentation/widgets/bottom_navbar.dart';

class UserCatalogScreen extends StatefulWidget {
  const UserCatalogScreen({super.key});

  @override
  State<UserCatalogScreen> createState() => _UserCatalogScreenState();
}

class _UserCatalogScreenState extends State<UserCatalogScreen> {
  late Future<List<Map<String, dynamic>>> _inventoryFuture;
  String _selectedCategory = 'ALL';
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _inventoryFuture = _fetchInventoryFromServer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      String rawUsername = 'Trailblazer';
      if (authState is AuthAuthenticated) {
        final email = authState.email;
        if (email.contains('@')) {
          rawUsername = email.split('@')[0];
        } else if (email.isNotEmpty) {
          rawUsername = email;
        }
      }
      final String capitalizedUsername =
          rawUsername.isEmpty
              ? 'Trailblazer'
              : (rawUsername.substring(0, 1).toUpperCase() +
                  rawUsername.substring(1));
      ProfileController.instance.loadProfileData(capitalizedUsername);
    });
  }

  /// Fetch catalog data dari REST API server (GET /api/resources).
  /// Jika server tidak dapat dijangkau, fallback ke data lokal.
  Future<List<Map<String, dynamic>>> _fetchInventoryFromServer() async {
    try {
      final serverItems = await ApiService.instance.getResources();
      // Normalize data dari server agar sesuai format yang diharapkan UI
      _allItems = serverItems.map((item) {
        final priceRaw = item['price'];
        final double price = priceRaw is int
            ? priceRaw.toDouble()
            : (priceRaw is double ? priceRaw : double.tryParse('$priceRaw') ?? 0.0);
        final stockRaw = item['stock'];
        final int stock = stockRaw is int
            ? stockRaw
            : int.tryParse('$stockRaw') ?? 0;
        final String type = (item['type'] ?? 'Unknown').toString();
        // Tentukan priceType berdasarkan tipe item
        final String priceType = (type.toUpperCase() == 'MATERIAL')
            ? 'CREDIT'
            : 'JADE';
        return {
          'id': item['id'],
          'name': item['name'] ?? 'Unknown',
          'type': type,
          'price': price,
          'priceType': item['priceType'] ?? priceType,
          'stock': stock,
          'image': item['image'] ?? '',
          'description': item['description'] ?? '',
        };
      }).toList();
    } catch (e) {
      // Fallback ke data lokal jika server tidak aktif
      ApiService.instance.log('Server unreachable, using local data. Error: $e');
      _allItems = [
        {
          'id': 'LC-001',
          'name': 'Before Dawn',
          'type': 'Light Cone',
          'price': 1280.0,
          'priceType': 'JADE',
          'stock': 0,
          'image': 'assets/images/beforeDawn.jpg',
        },
        {
          'id': 'LC-002',
          'name': 'Perfect Timing',
          'type': 'Light Cone',
          'price': 480.0,
          'priceType': 'JADE',
          'stock': 15,
          'image': 'assets/images/perfectTiming.jpg',
        },
        {
          'id': 'RSC-002',
          'name': 'Star Rail Pass',
          'type': 'Ticket',
          'price': 160.0,
          'priceType': 'JADE',
          'stock': 50,
          'image': 'assets/images/starRailPass.jpg',
        },
        {
          'id': 'RSC-003',
          'name': 'Tracks of Destiny',
          'type': 'Material',
          'price': 50000.0,
          'priceType': 'CREDIT',
          'stock': 5,
          'image': 'assets/images/tracksOfDestiny.jpg',
        },
      ];
    }
    _applyFilter();
    return _allItems;
  }

  void _applyFilter() {
    setState(() {
      List<Map<String, dynamic>> temp = [];
      if (_selectedCategory == 'ALL') {
        temp = _allItems;
      } else {
        temp = _allItems.where((item) {
          final type = item['type'].toString().toUpperCase();
          if (_selectedCategory == 'CURRENCY' && type == 'CURRENCY') return true;
          if (_selectedCategory == 'TICKETS' && type == 'TICKET') return true;
          if (_selectedCategory == 'MATERIALS' && type == 'MATERIAL') return true;
          if (_selectedCategory == 'LIGHT CONES' && type == 'LIGHT CONE') return true;
          return false;
        }).toList();
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        temp = temp.where((item) {
          final name = item['name'].toString().toLowerCase();
          final type = item['type'].toString().toLowerCase();
          final id = item['id'].toString().toLowerCase();
          return name.contains(query) || type.contains(query) || id.contains(query);
        }).toList();
      }

      _filteredItems = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get currently logged in user info
    final authState = context.read<AuthBloc>().state;
    bool isAdmin = false;
    if (authState is AuthAuthenticated) {
      isAdmin = authState.isAdmin;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220).withOpacity(0.85),
        elevation: 0,
        title: Text(
          'ASTRAL TERMINAL',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD4B375),
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
            fontSize: 22,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Dashboard User Profile & Stats Header Card (Condensed Horizontal Row)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: AppGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        // Left: circular gold-bordered user avatar placeholder (no level badge)
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: ValueListenableBuilder<String?>(
                            valueListenable: ProfileController.instance.avatarUrlNotifier,
                            builder: (context, avatarUrl, _) {
                              return Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFD4B375), width: 1.5),
                                  color: const Color(0xFF161F32),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: ProfileController.instance.buildAvatarWidget(avatarUrl, 44),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Center: Username text and UID text stacked vertically
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: ProfileController.instance.usernameNotifier,
                                builder: (context, username, _) {
                                  return Text(
                                    username.toUpperCase(),
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.0,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'UID: 802619420',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right: compact stacked vertical currency display
                        SizedBox(
                          width: 95,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ValueListenableBuilder<double>(
                                valueListenable: ProfileController.instance.jadesNotifier,
                                builder: (context, jades, _) {
                                  return _buildMiniCurrency(
                                    imagePath: 'assets/images/stellarJade.png',
                                    value: _formatBalanceNumber(jades),
                                    color: const Color(0xFF00FFCC),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              ValueListenableBuilder<double>(
                                valueListenable: ProfileController.instance.creditsNotifier,
                                builder: (context, credits, _) {
                                  return _buildMiniCurrency(
                                    imagePath: 'assets/images/credits.png',
                                    value: _formatBalanceNumber(credits),
                                    color: const Color(0xFFD4B375),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 1b. Search Manifest Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: AppGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                          _applyFilter();
                        });
                      },
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'SEARCH MANIFEST RESOURCES...',
                        hintStyle: GoogleFonts.rajdhani(
                          color: Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFD4B375),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _applyFilter();
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Horizontal Skewed Categories (Tabs)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 38,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryTab('ALL'),
                      _buildCategoryTab('TICKETS'),
                      _buildCategoryTab('MATERIALS'),
                      _buildCategoryTab('LIGHT CONES'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 3. Grid Catalog Manifest
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _inventoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFD4B375)),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'TERMINAL ERROR: ${snapshot.error}',
                          style: GoogleFonts.rajdhani(color: Colors.redAccent),
                        ),
                      );
                    }

                    if (_filteredItems.isEmpty) {
                      return Center(
                        child: Text(
                          'NO RESOURCES IN CATEGORY',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white38,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      );
                    }

                    final leftColumnItems = <Map<String, dynamic>>[];
                    final rightColumnItems = <Map<String, dynamic>>[];
                    for (int i = 0; i < _filteredItems.length; i++) {
                      if (i % 2 == 0) {
                        leftColumnItems.add(_filteredItems[i]);
                      } else {
                        rightColumnItems.add(_filteredItems[i]);
                      }
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: leftColumnItems.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: HsrGridTile(
                                    item: item,
                                    onTap: () {
                                      context.push('/resourceDetail', extra: item);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              children: rightColumnItems.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: HsrGridTile(
                                    item: item,
                                    onTap: () {
                                      context.push('/resourceDetail', extra: item);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        isAdmin: isAdmin,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              _selectedCategory = 'ALL';
              _applyFilter();
            });
          } else if (index == 1) {
            context.go('/warpMission');
          } else if (index == 2) {
            context.go('/profile');
          } else if (index == 3 && isAdmin) {
            context.go('/adminDashboard');
          }
        },
      ),
    );
  }

  String _formatBalanceNumber(double val) {
    if (val >= 1000000) {
      final double millions = val / 1000000;
      return millions == millions.toInt() ? '${millions.toInt()}M' : '${millions.toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      final double thousands = val / 1000;
      return thousands == thousands.toInt() ? '${thousands.toInt()}K' : '${thousands.toStringAsFixed(1)}K';
    }
    return val.toInt().toString();
  }

  Widget _buildMiniCurrency({
    IconData? icon,
    String? imagePath,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imagePath != null)
            SizedBox(
              width: 14,
              height: 14,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, st) =>
                    Icon(icon ?? Icons.diamond_outlined, color: color, size: 12),
              ),
            )
          else if (icon != null)
            Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCategoryTab(String categoryName) {
    final bool isSelected = _selectedCategory == categoryName;
    const Color activeBgColor = Color(0xFFD4B375);
    const Color activeTextColor = Color(0xFF0B1220);
    const Color inactiveBgColor = Color(0xFF161F32);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Transform(
        transform: Matrix4.skewX(-0.15), // angled HSR style
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = categoryName;
              _applyFilter();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? activeBgColor : inactiveBgColor.withOpacity(0.55),
              border: Border.all(
                color: isSelected ? activeBgColor : Colors.white24,
                width: 0.8,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeBgColor.withOpacity(0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Transform(
              transform: Matrix4.skewX(0.15), // Un-skew text inside
              child: Text(
                categoryName,
                style: GoogleFonts.rajdhani(
                  color: isSelected ? activeTextColor : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
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
    
    // Choose cyan or gold theme based on currency/priceType
    final bool isJade = item['priceType'] == 'JADE';
    final Color themeBorderColor = isJade
        ? const Color(0xFF00FFCC) // Glowing Cyan
        : const Color(0xFFD4B375); // Glowing Gold

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: Opacity(
        opacity: isOutOfStock ? 0.55 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161F32).withOpacity(0.75), // Translucent dark slate blue
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: themeBorderColor.withOpacity(0.35),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeBorderColor.withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper section: Stock Badge and Clean Placeholder Box (dedicated for future PNG)
                  Stack(
                    children: [
                      // Spacious clean placeholder container with dotted border
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: item['image'] != null && item['image'].toString().isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: themeBorderColor.withOpacity(0.35),
                                    width: 1.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildItemImage(item['image'].toString()),
                                ),
                              )
                            : CustomPaint(
                                painter: DottedBorderPainter(
                                  color: themeBorderColor.withOpacity(0.35),
                                  strokeWidth: 1.0,
                                  gap: 5.0,
                                ),
                                child: Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.01),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: isJade
                                        ? Opacity(
                                            opacity: 0.2,
                                            child: Image.asset(
                                              'assets/images/stellarJade.png',
                                              width: 28,
                                              height: 28,
                                            ),
                                          )
                                        : Opacity(
                                            opacity: 0.2,
                                            child: Image.asset(
                                              'assets/images/credits.png',
                                              width: 28,
                                              height: 28,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                      ),
                      // Stock status badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: HsrStockBadge(stock: item['stock']),
                      ),
                    ],
                  ),
                  // Bottom section: Solid darker sub-container
                  Container(
                    height: 52,
                    color: const Color(0xFF0B1220).withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left side: Item Title and Category Tag
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['name'].toString().toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['type'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white30,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Right side: Price compact — icon tight next to text
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 13,
                              height: 13,
                              child: Image.asset(
                                isJade
                                    ? 'assets/images/stellarJade.png'
                                    : 'assets/images/credits.png',
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, err, st) => Icon(
                                  isJade ? Icons.diamond_outlined : Icons.toll,
                                  color: themeBorderColor,
                                  size: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _formatPrice(item['price']),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rajdhani(
                                color: themeBorderColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Renders image from local asset path OR network URL.
  Widget _buildItemImage(String imagePath) {
    const errorWidget = SizedBox(
      height: 120,
      child: Center(child: Icon(Icons.broken_image, color: Colors.white30)),
    );
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.fitWidth,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator(color: Color(0xFFD4B375), strokeWidth: 1.5)),
          );
        },
        errorBuilder: (ctx, err, st) => errorWidget,
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.fitWidth,
      errorBuilder: (ctx, err, st) => errorWidget,
    );
  }

  String _formatPrice(dynamic price) {
    if (price is int) return price.toString();
    if (price is double) {
      if (price == price.toInt()) {
        return price.toInt().toString();
      }
      return price.toStringAsFixed(0);
    }
    return price.toString();
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
        ? const Color(0xFFD4B375) // Gold
        : const Color(0xFFE53935); // Strike Red
    final String label = hasStock ? 'Stock: $stock' : 'DEPLETED';

    return Transform(
      transform: Matrix4.skewX(-0.15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Transform(
          transform: Matrix4.skewX(0.15),
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              color: hasStock ? const Color(0xFF0B1220) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// --- Component 6: DottedBorderPainter ---
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

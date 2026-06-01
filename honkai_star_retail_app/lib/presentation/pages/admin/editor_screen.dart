import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:honkai_star_retail_app/core/services/api_service.dart';
import 'package:honkai_star_retail_app/presentation/widgets/constellation_background.dart';
import 'package:honkai_star_retail_app/presentation/widgets/glass_card.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();

  bool _isLoading = false;
  String _selectedCategory = 'Light Cone';
  String _selectedCurrency = 'JADE';
  String _selectedGlow = 'GOLD';

  final List<String> _categories = ['Currency', 'Ticket', 'Material', 'Light Cone'];
  final List<String> _currencies = ['JADE', 'CREDIT'];
  final List<String> _glows = ['CYAN', 'GOLD'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _synthesizeResource() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String name = _nameController.text.trim();
    final double price = double.tryParse(_priceController.text) ?? 0.0;
    final int stock = int.tryParse(_stockController.text) ?? 0;
    final String description = _descController.text.trim();

    try {
      await ApiService.instance.createResource({
        'name': name,
        'type': _selectedCategory,
        'description': description,
        'stock': stock,
        'price': price,
        'image': '', // No image upload for now
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: AppGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedGlow == 'GOLD' ? const Color(0xFFD4B375) : const Color(0xFF00FFCC),
                          width: 1.5,
                        ),
                        color: const Color(0xFF0B1220),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: _selectedGlow == 'GOLD' ? const Color(0xFFD4B375) : const Color(0xFF00FFCC),
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SYNTHESIS COMPLETE',
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFFD4B375),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Successfully synthesized "$name" and saved to the Astral Express Retail Database.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.black26,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Category: $_selectedCategory', style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 13)),
                          Text('Value: ${_priceController.text} $_selectedCurrency', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('Initial Stock: ${_stockController.text} units', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _nameController.clear();
                            _priceController.clear();
                            _stockController.clear();
                            _descController.clear();
                            setState(() {
                              _selectedCategory = 'Light Cone';
                              _selectedCurrency = 'JADE';
                              _selectedGlow = 'GOLD';
                            });
                          },
                          child: Text(
                            'CONFIRM',
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFFD4B375),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SYNTHESIS FAILED: $e',
            style: GoogleFonts.rajdhani(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE53935),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeThemeColor = _selectedGlow == 'GOLD' ? const Color(0xFFD4B375) : const Color(0xFF00FFCC);

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
          'MANIFEST SYNTHESIZER',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'GENERATE QUANTUM MANIFEST',
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
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Resource Name
                          Text('Resource Title / Label', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.rajdhani(color: Colors.white),
                            decoration: _buildInputDecoration(hint: 'e.g. Before Dawn', activeColor: activeThemeColor),
                            validator: (val) => (val == null || val.isEmpty) ? 'Item name required' : null,
                          ),
                          const SizedBox(height: 16),

                          // 1b. Description
                          Text('Description', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _descController,
                            style: GoogleFonts.rajdhani(color: Colors.white),
                            maxLines: 2,
                            decoration: _buildInputDecoration(hint: 'Short description (optional)', activeColor: activeThemeColor),
                          ),
                          const SizedBox(height: 16),

                          // 2. Row: Category & Stock
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Category', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: _selectedCategory,
                                      style: GoogleFonts.rajdhani(color: Colors.white),
                                      dropdownColor: const Color(0xFF161F32),
                                      decoration: _buildInputDecoration(hint: '', activeColor: activeThemeColor),
                                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedCategory = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Stock Quantity', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _stockController,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.rajdhani(color: Colors.white),
                                      decoration: _buildInputDecoration(hint: 'e.g. 50', activeColor: activeThemeColor),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Stock level required';
                                        if (int.tryParse(val) == null) return 'Must be an integer';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 3. Row: Price & Currency Type
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Unit Price', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.rajdhani(color: Colors.white),
                                      decoration: _buildInputDecoration(hint: 'e.g. 160', activeColor: activeThemeColor),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Price required';
                                        if (double.tryParse(val) == null) return 'Must be a number';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Price Currency', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: _selectedCurrency,
                                      style: GoogleFonts.rajdhani(color: Colors.white),
                                      dropdownColor: const Color(0xFF161F32),
                                      decoration: _buildInputDecoration(hint: '', activeColor: activeThemeColor),
                                      items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedCurrency = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 4. Glow Color Border Theme
                          Text('Glowing Border Accent', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedGlow,
                            style: GoogleFonts.rajdhani(color: Colors.white),
                            dropdownColor: const Color(0xFF161F32),
                            decoration: _buildInputDecoration(hint: '', activeColor: activeThemeColor),
                            items: _glows.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGlow = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                   // Action Button
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFFD4B375)),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeThemeColor,
                            foregroundColor: const Color(0xFF0B1220),
                            shape: const BeveledRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shadowColor: activeThemeColor.withOpacity(0.4),
                            elevation: 8,
                          ),
                          onPressed: _synthesizeResource,
                          child: Text(
                            'SYNTHESIZE NEW RESOURCE',
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
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required Color activeColor}) {
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
        borderSide: BorderSide(color: activeColor),
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

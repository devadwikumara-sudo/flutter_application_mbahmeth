import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/customer/catalog.dart';
import 'package:flutter_application_mbahmeth/customer/keranjang_page.dart';
import 'package:flutter_application_mbahmeth/customer/detail.dart';
import 'package:flutter_application_mbahmeth/customer/notification_screen.dart';
import 'package:flutter_application_mbahmeth/customer/profil_screen.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentUserId = 0;
  int _currentBannerIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;
  int _bottomNavIndex = 0;

  // ── PERBAIKAN: Menggunakan CartPageState (tanpa underscore) agar bisa diakses ──
 final GlobalKey<CartPageState> _cartKey = GlobalKey<CartPageState>();

  final ApiService _api = ApiService();
  List<dynamic> _featuredProducts = [];
  bool _loadingFeatured = true;

  final List<String> _dummyBannerImages = [
    'assets/images/screen1.png',
    'assets/images/screen2.png',
    'assets/images/screen3.png',
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _loadUserId();
    _loadFeaturedProducts();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _currentUserId = prefs.getInt('id_user') ?? 0);
    }
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final products = await _api.getFeaturedProducts();
      if (mounted) {
        setState(() {
          _featuredProducts = products;
          _loadingFeatured = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingFeatured = false);
    }
  }

  void _startBannerTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        _currentBannerIndex =
            (_currentBannerIndex + 1) % _dummyBannerImages.length;
      });
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final double nilai = double.tryParse(harga.toString()) ?? 0;
    return nilai.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _handleCartNavigation() {
    if (_currentUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan login terlebih dahulu'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    // ── PERBAIKAN: Memanggil loadCart() (tanpa underscore) ──
    _cartKey.currentState?.loadCart();
    setState(() => _bottomNavIndex = 1);
  }

  String _namaKategori(dynamic idCategory) {
    switch (idCategory?.toString()) {
      case '1':
        return 'OBAT PERTANIAN';
      case '2':
        return 'PUPUK';
      case '3':
        return 'BIBIT / BENIH';
      case '4':
        return 'ALAT PERTANIAN';
      default:
        return 'PRODUK';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          // Tab 0: Beranda
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: _loadFeaturedProducts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopSection(),
                    _buildCategorySection(),
                    _buildProductSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Tab 1: Keranjang dengan GlobalKey yang sudah diperbaiki
          CartPage(
            key: _cartKey,
            userId: _currentUserId,
            currentIndex: 1,
            onNavTap: (i) => setState(() => _bottomNavIndex = i),
          ),
          const NotificationScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
              _buildNavItem(1, Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'Keranjang', onTap: _handleCartNavigation),
              _buildNavItem(2, Icons.notifications_rounded, Icons.notifications_none_rounded, 'Notifikasi'),
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, {VoidCallback? onTap}) {
    final bool isActive = _bottomNavIndex == index;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _bottomNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryGreen.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.primaryGreen : AppColors.textLight,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
              color: isActive ? AppColors.primaryGreen : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Halo, Petani! 👋', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('MbahMeth Store', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                ],
              ),
              GestureDetector(
                onTap: _handleCartNavigation,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Cari pupuk, bibit, obat pertanian...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 155,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentBannerIndex = i),
                itemCount: _dummyBannerImages.length,
                itemBuilder: (_, i) => Image.asset(_dummyBannerImages[i], fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _dummyBannerImages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentBannerIndex == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(color: _currentBannerIndex == i ? Colors.white : Colors.white38, borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {'image': 'assets/images/Obat Pertanian.png', 'label': 'Obat', 'id': 1},
      {'image': 'assets/images/Pupuk.png', 'label': 'Pupuk', 'id': 2},
      {'image': 'assets/images/BibitBenih.png', 'label': 'Bibit', 'id': 3},
      {'image': 'assets/images/Alat Pertanian.png', 'label': 'Alat', 'id': 4},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories.map((c) => _buildCategoryItem(c['image'] as String, c['label'] as String, c['id'] as int)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String imagePath, String label, int idCategory) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen(categoryName: label, idCategory: idCategory))),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder), boxShadow: AppColors.cardShadow),
            child: Center(child: Image.asset(imagePath, width: 38, height: 38)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Produk Rekomendasi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 14),
          if (_loadingFeatured)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primaryGreen)))
          else if (_featuredProducts.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textLight), const SizedBox(height: 8), const Text('Tidak ada produk', style: TextStyle(color: AppColors.textLight))])) )
          else
            ..._featuredProducts.map(_buildProductCard).toList(),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic item) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(product: Map<String, dynamic>.from(item)))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder), boxShadow: AppColors.cardShadow),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                '${ApiService.imageUrl}${item['gambar_produk'] ?? ''}',
                width: 95, height: 95, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 95, height: 95, color: AppColors.successLight, child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 32)),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(width: 95, height: 95, color: AppColors.surfaceGrey, child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen))));
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)), child: Text(_namaKategori(item['id_category']), style: const TextStyle(color: AppColors.primaryGreenDark, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4))),
                  const SizedBox(height: 8),
                  Text(item['nama_produk'] ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('Rp ${_formatHarga(item['harga'])}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 22),
          ],
        ),
      ),
    );
  }
}
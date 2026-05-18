import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final GlobalKey<CartPageState> _cartKey = GlobalKey<CartPageState>();
  final ApiService _api = ApiService();

  // ── Data per kategori (id: 1=Obat, 2=Pupuk, 3=Bibit, 4=Alat) ──
  Map<int, List<dynamic>> _categoryProducts = {};
  bool _loadingProducts = true;

  // ── Search ──
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allProducts = [];
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  final List<String> _dummyBannerImages = [
    'assets/images/screen1.png',
    'assets/images/screen2.png',
    'assets/images/screen3.png',
  ];

  // Urutan & info kategori
  static const List<Map<String, dynamic>> _categoryMeta = [
    {'id': 3, 'label': 'Bibit / Benih', 'icon': Icons.grass_rounded},
    {'id': 2, 'label': 'Pupuk', 'icon': Icons.science_rounded},
    {'id': 1, 'label': 'Obat Pertanian', 'icon': Icons.medical_services_rounded},
    {'id': 4, 'label': 'Alat Pertanian', 'icon': Icons.agriculture_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _loadUserId();
    _loadAllCategoryProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Load user id ──────────────────────────────────────────────────────────
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _currentUserId = prefs.getInt('id_user') ?? 0);
    }
  }

  // ── Ambil 2 produk per kategori ──────────────────────────────────────────
  Future<void> _loadAllCategoryProducts() async {
    setState(() => _loadingProducts = true);

    final Map<int, List<dynamic>> result = {};
    final List<dynamic> allProducts = [];

    for (final cat in _categoryMeta) {
      try {
        final products = await _api.getProducts(cat['id'] as int);
        // Ambil hanya 2 produk pertama yang stoknya > 0
        final available = products
            .where((p) => (int.tryParse(p['stok']?.toString() ?? '0') ?? 0) > 0)
            .toList();
        result[cat['id'] as int] = available.take(2).toList();
        allProducts.addAll(products); // simpan semua untuk search
      } catch (_) {
        result[cat['id'] as int] = [];
      }
    }

    if (mounted) {
      setState(() {
        _categoryProducts = result;
        _allProducts = allProducts;
        _loadingProducts = false;
      });
    }
  }

  // ── Search logic ─────────────────────────────────────────────────────────
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = _allProducts.where((p) {
          final nama = (p['nama_produk'] ?? '').toString().toLowerCase();
          final desc = (p['deskripsi'] ?? '').toString().toLowerCase();
          return nama.contains(query) || desc.contains(query);
        }).toList();
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  // ── Banner timer ─────────────────────────────────────────────────────────
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

  // ── Format harga ─────────────────────────────────────────────────────────
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
    _cartKey.currentState?.loadCart();
    setState(() => _bottomNavIndex = 1);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // Jika tidak sedang di tab Beranda, kembali ke Beranda dulu
        if (_bottomNavIndex != 0) {
          setState(() => _bottomNavIndex = 0);
          return;
        }
        // Sudah di tab Beranda → tampilkan dialog keluar
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Keluar Aplikasi?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
                'Apakah Anda yakin ingin keluar dari aplikasi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal',
                    style: TextStyle(color: AppColors.textMedium)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Keluar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (shouldExit == true && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      // ── Background full hijau gradasi ──
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1F6B00),
              Color(0xFF2E9900),
              Color(0xFF3DB800),
              Color(0xFFE8F5E2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.25, 0.45, 1.0],
          ),
        ),
        child: IndexedStack(
          index: _bottomNavIndex,
          children: [
            // Tab 0: Beranda
            SafeArea(
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: _loadAllCategoryProducts,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopSection(),
                      // Konten utama di atas kartu putih
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4FAF2),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(32)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Pencarian aktif / konten normal ──
                            if (_isSearching)
                              _buildSearchResults()
                            else ...[
                              _buildCategorySection(),
                              _buildAllCategoryProductSections(),
                              const SizedBox(height: 32),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Tab 1: Keranjang
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
      ),
      bottomNavigationBar: _buildBottomNav(),
      ), // end Scaffold
    ); // end PopScope
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────────────────────────────────────
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
              _buildNavItem(1, Icons.shopping_bag_rounded,
                  Icons.shopping_bag_outlined, 'Keranjang',
                  onTap: _handleCartNavigation),
              _buildNavItem(2, Icons.notifications_rounded,
                  Icons.notifications_none_rounded, 'Notifikasi'),
              _buildNavItem(3, Icons.person_rounded,
                  Icons.person_outline_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label,
      {VoidCallback? onTap}) {
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
              color: isActive
                  ? AppColors.primaryGreen.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isActive ? activeIcon : inactiveIcon,
              color:
                  isActive ? AppColors.primaryGreen : AppColors.textLight,
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

  // ─────────────────────────────────────────────────────────────────────────
  // TOP SECTION (header + search + banner) — tetap transparan di atas gradient
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting + cart icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo, Petani! 👋',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('MbahMeth Store',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3)),
                ],
              ),
              GestureDetector(
                onTap: _handleCartNavigation,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Search bar AKTIF ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pupuk, bibit, obat pertanian...',
                hintStyle:
                    const TextStyle(color: AppColors.textHint, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.primaryGreen),
                suffixIcon: _isSearching
                    ? GestureDetector(
                        onTap: _clearSearch,
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textLight),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 4),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Banner (sembunyikan saat search aktif)
          if (!_isSearching) ...[
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) =>
                      setState(() => _currentBannerIndex = i),
                  itemCount: _dummyBannerImages.length,
                  itemBuilder: (_, i) => Image.asset(
                    _dummyBannerImages[i],
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
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
                  decoration: BoxDecoration(
                      color: _currentBannerIndex == i
                          ? Colors.white
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH RESULTS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _searchResults.isEmpty
                ? 'Tidak ada hasil untuk "${_searchController.text}"'
                : '${_searchResults.length} hasil untuk "${_searchController.text}"',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium),
          ),
          const SizedBox(height: 14),
          if (_searchResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 56, color: AppColors.textLight),
                    const SizedBox(height: 12),
                    const Text('Produk tidak ditemukan',
                        style: TextStyle(
                            color: AppColors.textLight, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            ..._searchResults.map(_buildProductCard),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KATEGORI
  // ─────────────────────────────────────────────────────────────────────────
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
          const Text('Kategori',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories
                .map((c) => _buildCategoryItem(
                    c['image'] as String,
                    c['label'] as String,
                    c['id'] as int))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String imagePath, String label, int idCategory) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CatalogScreen(
                  categoryName: label, idCategory: idCategory))),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.cardShadow),
            child: Center(child: Image.asset(imagePath, width: 38, height: 38)),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEMUA SEKSI PRODUK PER KATEGORI
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAllCategoryProductSections() {
    if (_loadingProducts) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
            child:
                CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Column(
      children: _categoryMeta.map((cat) {
        final id = cat['id'] as int;
        final label = cat['label'] as String;
        final products = _categoryProducts[id] ?? [];
        return _buildCategoryProductSection(
            id: id, label: label, products: products);
      }).toList(),
    );
  }

  Widget _buildCategoryProductSection({
    required int id,
    required String label,
    required List<dynamic> products,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header seksi ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CatalogScreen(
                            categoryName: label, idCategory: id))),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Lihat Semua',
                      style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Produk (max 2) ──
          if (products.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Belum ada produk tersedia',
                    style: TextStyle(
                        color: AppColors.textLight, fontSize: 13)),
              ),
            )
          else
            ...products.map(_buildProductCard),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CARD PRODUK
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProductCard(dynamic item) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  DetailScreen(product: Map<String, dynamic>.from(item)))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.cardShadow),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                '${ApiService.imageUrl}${item['gambar_produk'] ?? ''}',
                width: 95,
                height: 95,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                    width: 95,
                    height: 95,
                    color: AppColors.successLight,
                    child: const Icon(Icons.eco_rounded,
                        color: AppColors.primaryGreen, size: 32)),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                      width: 95,
                      height: 95,
                      color: AppColors.surfaceGrey,
                      child: const Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryGreen))));
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      _namaKategori(item['id_category']),
                      style: const TextStyle(
                          color: AppColors.primaryGreenDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item['nama_produk'] ?? '-',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('Rp ${_formatHarga(item['harga'])}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight, size: 22),
          ],
        ),
      ),
    );
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
}
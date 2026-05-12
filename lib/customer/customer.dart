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

  final ApiService _api = ApiService();
  List<dynamic> _featuredProducts = [];
  bool _loadingFeatured = true;

  final List<String> _dummyBannerImages = [
    'assets/images/screen1.png',
    'assets/images/screen2.png',
    'assets/images/screen3.png',
  ];

  // Halaman untuk setiap tab (kecuali Keranjang yang pakai push)
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeTab(
        bannerImages: _dummyBannerImages,
        pageController: _pageController,
        onBannerChanged: (i) =>
            setState(() => _currentBannerIndex = i),
        currentBannerIndex: _currentBannerIndex,
        featuredProducts: _featuredProducts,
        loadingFeatured: _loadingFeatured,
        formatHarga: _formatHarga,
        onRefresh: _loadFeaturedProducts,
        onProductTap: (item) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
                product: Map<String, dynamic>.from(item)),
          ),
        ),
        onCategoryTap: (label, id) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CatalogScreen(categoryName: label, idCategory: id),
          ),
        ),
      ),
      const NotificationScreen(),
      const ProfileScreen(),
    ];
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
    _timer =
        Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentBannerIndex < _dummyBannerImages.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
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
    return nilai
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  // Label AppBar tiap tab
  String get _appBarTitle {
    switch (_bottomNavIndex) {
      case 1:
        return 'Notifikasi';
      case 2:
        return 'Profil';
      default:
        return 'Toko MbahMeth';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bottomNavIndex == 0
          ? const Color(0xFFD4F3C6)
          : Colors.white,
      appBar: _bottomNavIndex == 0
          ? null // Halaman beranda punya header sendiri
          : AppBar(
              backgroundColor: const Color(0xFF339F16),
              elevation: 0,
              centerTitle: true,
              title: Text(
                _appBarTitle,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              // Tombol keranjang di AppBar tab lain
              actions: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                  onPressed: () {
                    if (_currentUserId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Silakan login terlebih dahulu')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CartPage(userId: _currentUserId),
                      ),
                    );
                  },
                ),
              ],
            ),

      // ── Body: IndexedStack supaya state tab tidak hilang ──
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          // Tab 0: Beranda (tetap pakai widget lama agar banner & produk jalan)
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // Tab 1: Notifikasi
          const NotificationScreen(),
          // Tab 2: Profil
          const ProfileScreen(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: AppColors.primaryGreen,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            currentIndex: _bottomNavIndex,
            onTap: (index) {
              // Tab 1 (index 1 lama) adalah Keranjang → push
              // Sekarang urutan: 0=Beranda, 1=Keranjang, 2=Notifikasi, 3=Profil
              if (index == 1) {
                // Keranjang → tetap push, tidak ubah _bottomNavIndex
                if (_currentUserId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Silakan login terlebih dahulu')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartPage(userId: _currentUserId),
                  ),
                );
              } else {
                // index 0 → Beranda (bottomNavIndex 0)
                // index 2 → Notifikasi (bottomNavIndex 1)
                // index 3 → Profil (bottomNavIndex 2)
                final pageIndex = index == 0
                    ? 0
                    : index == 2
                        ? 1
                        : 2;
                setState(() => _bottomNavIndex = pageIndex);
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(_bottomNavIndex == 0
                    ? Icons.home_filled
                    : Icons.home_outlined),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    // Badge jumlah item keranjang (opsional, bisa dikembangkan)
                  ],
                ),
                label: 'Keranjang',
              ),
              BottomNavigationBarItem(
                icon: Icon(_bottomNavIndex == 1
                    ? Icons.notifications
                    : Icons.notifications_none),
                label: 'Notifikasi',
              ),
              BottomNavigationBarItem(
                icon: Icon(_bottomNavIndex == 2
                    ? Icons.person
                    : Icons.person_outline),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget Beranda ────────────────────────────────────────────────
  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Pencarian',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentBannerIndex = index),
                itemCount: _dummyBannerImages.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _dummyBannerImages[index],
                    fit: BoxFit.fitWidth,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Indikator banner
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _dummyBannerImages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentBannerIndex == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentBannerIndex == i
                      ? AppColors.primaryGreen
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryItem(
                  'assets/images/Obat Pertanian.png',
                  'Obat Pertanian',
                  1),
              _buildCategoryItem('assets/images/Pupuk.png', 'Pupuk', 2),
              _buildCategoryItem(
                  'assets/images/BibitBenih.png', 'Bibit / Benih', 3),
              _buildCategoryItem(
                  'assets/images/Alat Pertanian.png',
                  'Alat Pertanian',
                  4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      String imagePath, String label, int idCategory) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CatalogScreen(
              categoryName: label, idCategory: idCategory),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Center(
              child: Image.asset(imagePath,
                  width: 44, height: 44, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              'Produk Terlaris',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
          ),
          if (_loadingFeatured)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen),
              ),
            )
          else if (_featuredProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('Belum ada produk tersedia',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...List.generate(_featuredProducts.length, (index) {
              final item = _featuredProducts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProductCard(item),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic item) {
    final String namaKategori = _namaKategori(item['id_category']);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DetailScreen(product: Map<String, dynamic>.from(item)),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(namaKategori,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['nama_produk'] ?? '-',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          color: AppColors.primaryGreen, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "Rp ${_formatHarga(item['harga'])}",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                  product:
                                      Map<String, dynamic>.from(item)),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC8F0CC),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10)),
                          child: const Text('Detail',
                              style: TextStyle(
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primaryGreen, width: 2)),
                        child: const Icon(Icons.check,
                            color: AppColors.primaryGreen, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  '${ApiService.imageUrl}${item['gambar_produk'] ?? ''}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image,
                        size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
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
        return 'TERLARIS';
    }
  }
}

// ── Placeholder class (tidak dipakai, hanya agar tidak error jika ada ref) ──
class _HomeTab extends StatelessWidget {
  final List<String> bannerImages;
  final PageController pageController;
  final Function(int) onBannerChanged;
  final int currentBannerIndex;
  final List<dynamic> featuredProducts;
  final bool loadingFeatured;
  final String Function(dynamic) formatHarga;
  final Future<void> Function() onRefresh;
  final void Function(dynamic) onProductTap;
  final void Function(String, int) onCategoryTap;

  const _HomeTab({
    required this.bannerImages,
    required this.pageController,
    required this.onBannerChanged,
    required this.currentBannerIndex,
    required this.featuredProducts,
    required this.loadingFeatured,
    required this.formatHarga,
    required this.onRefresh,
    required this.onProductTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
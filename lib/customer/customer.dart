import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentBannerIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;
  int _bottomNavIndex = 0;

  final List<String> _dummyBannerImages = [
    'assets/images/screen1.png',
    'assets/images/screen2.png',
    'assets/images/screen3.png',
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopSection(),
              _buildCategorySection(),
              _buildProductSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 10),
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
              setState(() {
                _bottomNavIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Keranjang'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifikasi'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      // Padding atas tetap saya beri 24.0 agar ada jarak dari status bar
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
            height: 200, // Ukuran tinggi box banner (bisa Anda sesuaikan)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemCount: _dummyBannerImages.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _dummyBannerImages[index],
                    // --- PENGATURAN UKURAN GAMBAR ---
                    fit: BoxFit.fitWidth, 
                    /* Ganti BoxFit di atas sesuai keinginan:
                       - BoxFit.contain: Seluruh gambar akan terlihat (tidak terpotong), 
                                         tapi mungkin ada ruang kosong di sisi samping.
                       - BoxFit.fill: Gambar akan dipaksa memenuhi kotak (mungkin jadi gepeng).
                       - BoxFit.fitWidth: Lebar gambar pas dengan kotak, tinggi mengikuti.
                    */
                  );
                },
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryItem(Icons.medication_liquid, 'Obat Pertanian'),
              _buildCategoryItem(Icons.water_drop, 'Pupuk'),
              _buildCategoryItem(Icons.grass, 'Bibit / Benih'),
              _buildCategoryItem(Icons.agriculture, 'Alat Pertanian'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Center(child: Icon(icon, color: AppColors.primaryGreen, size: 36)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        ),
      ],
    );
  }

  Widget _buildProductSection() {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildProductCard('INTEKSIDA ARJUNA 200', 'Rp.7.000', Colors.grey[300]!),
          const SizedBox(height: 16),
          _buildProductCard('CIHERANG 5KG', 'Rp.65.000', Colors.grey[400]!),
          const SizedBox(height: 24),
          _buildProductCard('JAGUNG PERKASA', 'Rp.26.000', Colors.grey[400]!),
          const SizedBox(height: 24),
          _buildProductCard('KNO MERAH', 'Rp.12.250', Colors.grey[400]!),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, String price, Color imagePlaceholderColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(12)),
                  child: const Text('TERLARIS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.2)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: AppColors.primaryGreen, size: 18),
                    const SizedBox(width: 4),
                    Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC8F0CC), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text('Detail', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryGreen, width: 2)), child: const Icon(Icons.check, color: AppColors.primaryGreen, size: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 130, height: 150,
            decoration: BoxDecoration(color: imagePlaceholderColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24), topLeft: Radius.circular(80), bottomLeft: Radius.circular(80))),
            child: const Center(child: Icon(Icons.image, size: 40, color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
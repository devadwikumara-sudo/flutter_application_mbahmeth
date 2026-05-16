import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/primary_button.dart';
import 'package:flutter_application_mbahmeth/customer/keranjang_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int jumlah = 1;
  late int stokMax;
  bool _loading = false;
  final ApiService _api = ApiService();
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    stokMax =
        int.tryParse(widget.product['stok']?.toString() ?? '0') ?? 0;
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _currentUserId = prefs.getInt('id_user') ?? 0);
    }
  }

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final double nilai = double.tryParse(harga.toString()) ?? 0;
    return nilai.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _tambahKeKeranjang() async {
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
    if (_loading) return;
    setState(() => _loading = true);

    final result = await _api.addToCart(
      userId: _currentUserId,
      productId:
          int.tryParse(widget.product['id_product']?.toString() ?? '0') ?? 0,
      jumlah: jumlah,
      harga: double.tryParse(
              widget.product['harga']?.toString() ?? '0') ??
          0,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Berhasil masuk keranjang!'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Lihat',
            textColor: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CartPage(userId: _currentUserId)),
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal masuk keranjang'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final double harga =
        double.tryParse(product['harga']?.toString() ?? '0') ?? 0;
    final double totalHarga = harga * jumlah;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // ── Gambar + Header overlay ──
          Stack(
            children: [
              // Gambar produk
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.network(
                  '${ApiService.imageUrl}${product['gambar_produk'] ?? ''}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.successLight,
                    child: const Center(
                      child: Icon(Icons.eco_rounded,
                          size: 80, color: AppColors.primaryGreen),
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.surfaceGrey,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen),
                      ),
                    );
                  },
                ),
              ),

              // Gradient overlay bawah gambar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 80,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black26],
                    ),
                  ),
                ),
              ),

              // Tombol back & cart
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      _circleButton(
                        icon: Icons.shopping_cart_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CartPage(userId: _currentUserId),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Detail Produk (scrollable) ──
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama & Harga
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product['nama_produk'] ?? '-',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rp ${_formatHarga(product['harga'])}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Badge stok
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: stokMax > 0
                              ? AppColors.successLight
                              : AppColors.primaryRedLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              stokMax > 0
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.remove_circle_outline_rounded,
                              size: 14,
                              color: stokMax > 0
                                  ? AppColors.primaryGreen
                                  : AppColors.primaryRed,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              stokMax > 0
                                  ? 'Stok tersedia: $stokMax'
                                  : 'Stok Habis',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: stokMax > 0
                                    ? AppColors.primaryGreen
                                    : AppColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),

                      // Deskripsi
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['deskripsi'] ?? 'Tidak ada deskripsi.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Counter jumlah
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Jumlah',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Spacer(),
                            // Tombol -
                            _counterButton(
                              icon: Icons.remove_rounded,
                              enabled: jumlah > 1,
                              onTap: () {
                                if (jumlah > 1) {
                                  setState(() => jumlah--);
                                }
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Text(
                                '$jumlah',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            // Tombol +
                            _counterButton(
                              icon: Icons.add_rounded,
                              enabled: jumlah < stokMax,
                              onTap: () {
                                if (jumlah < stokMax) {
                                  setState(() => jumlah++);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Total
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Harga',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textMedium,
                              ),
                            ),
                            Text(
                              'Rp ${_formatHarga(totalHarga)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol keranjang
                      PrimaryButton(
                        text: stokMax > 0
                            ? 'Masukkan Keranjang'
                            : 'Stok Habis',
                        onPressed: stokMax > 0 ? _tambahKeKeranjang : null,
                        isLoading: _loading,
                        icon: stokMax > 0
                            ? const Icon(Icons.shopping_cart_outlined,
                                color: Colors.white, size: 20)
                            : null,
                        backgroundColor:
                            stokMax == 0 ? AppColors.textLight : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textDark, size: 20),
      ),
    );
  }

  Widget _counterButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryGreen : AppColors.surfaceGrey,
          shape: BoxShape.circle,
          boxShadow: enabled ? AppColors.greenShadow : null,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
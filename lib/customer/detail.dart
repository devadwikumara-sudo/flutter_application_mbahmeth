import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
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
    stokMax = int.tryParse(widget.product['stok']?.toString() ?? '0') ?? 0;
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentUserId = prefs.getInt('id_user') ?? 0;
      });
    }
  }

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final double nilai = double.tryParse(harga.toString()) ?? 0;
    return nilai
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _tambahKeKeranjang() async {
    if (_currentUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }
    if (_loading) return;
    setState(() => _loading = true);

    final result = await _api.addToCart(
      userId: _currentUserId,
      productId: int.tryParse(
              widget.product['id_product']?.toString() ?? '0') ??
          0,
      jumlah: jumlah,
      harga: double.tryParse(widget.product['harga']?.toString() ?? '0') ?? 0,
    );

    setState(() => _loading = false);

    if (!mounted) return;
    final scaffoldMsg = ScaffoldMessenger.of(context);

    if (result['status'] == 'success') {
      scaffoldMsg.showSnackBar(
        SnackBar(
          content: const Text("Berhasil masuk keranjang!"),
          backgroundColor: const Color(0xFF339F16),
          action: SnackBarAction(
            label: 'Lihat Keranjang',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartPage(userId: _currentUserId),
                ),
              );
            },
          ),
        ),
      );
    } else {
      scaffoldMsg.showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal masuk keranjang'),
          backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text("Detail Produk"),
        backgroundColor: const Color(0xFF339F16),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CartPage(userId: _currentUserId)),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gambar Produk ──
            Image.network(
              '${ApiService.imageUrl}${product['gambar_produk'] ?? ''}',
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 280,
                color: const Color(0xFFF0F0F0),
                child: const Center(
                    child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Nama & Harga ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product['nama_produk'] ?? '-',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Rp ${_formatHarga(product['harga'])}",
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF339F16),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // ── Badge stok ──
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stokMax > 0
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stokMax > 0 ? "Stok tersedia: $stokMax" : "Stok Habis",
                      style: TextStyle(
                        fontSize: 12,
                        color: stokMax > 0 ? Colors.green[700] : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Deskripsi ──
                  const Text("Deskripsi",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(
                    product['deskripsi'] ?? 'Tidak ada deskripsi.',
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                  ),

                  const SizedBox(height: 24),

                  // ── Counter Jumlah ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text("Jumlah",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        const Spacer(),
                        // Tombol -
                        GestureDetector(
                          onTap: () {
                            if (jumlah > 1) setState(() => jumlah--);
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: jumlah > 1
                                  ? const Color(0xFF339F16)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "$jumlah",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Tombol +
                        GestureDetector(
                          onTap: () {
                            if (jumlah < stokMax) setState(() => jumlah++);
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: jumlah < stokMax
                                  ? const Color(0xFF339F16)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Total ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(
                        "Rp ${_formatHarga(totalHarga)}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF339F16)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Tombol Masukkan Keranjang ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: stokMax > 0
                            ? const Color(0xFF339F16)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: stokMax > 0 ? _tambahKeKeranjang : null,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              stokMax > 0
                                  ? "Masukkan Keranjang"
                                  : "Stok Habis",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
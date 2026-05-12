import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/customer/detail.dart';

class CatalogScreen extends StatefulWidget {
  final String categoryName;
  final int idCategory;

  const CatalogScreen({
    super.key,
    required this.categoryName,
    required this.idCategory,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _products = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final result = await _api.getProducts(widget.idCategory);
      if (mounted) {
        setState(() {
          _products = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: const Color(0xFF339F16),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF339F16)),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              "Tidak dapat terhubung ke server",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF339F16)),
              onPressed: _fetchProducts,
              child: const Text("Coba Lagi",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text("Produk tidak ditemukan",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF339F16),
      onRefresh: _fetchProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final item = _products[index];
          final int stok =
              int.tryParse(item['stok']?.toString() ?? '0') ?? 0;

          return GestureDetector(
            onTap: () => _bukaDetail(item),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Gambar Produk ──
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: Image.network(
                        '${ApiService.imageUrl}${item['gambar_produk'] ?? ''}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFF0F0F0),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF339F16), strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Center(
                            child: Icon(Icons.image_outlined,
                                color: Colors.grey, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Info & Tombol ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama_produk'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rp ${_formatHarga(item['harga'])}",
                          style: const TextStyle(
                              color: Color(0xFF339F16),
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stok > 0 ? "Stok: $stok" : "Habis",
                          style: TextStyle(
                            fontSize: 11,
                            color: stok > 0 ? Colors.grey : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: stok > 0
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF339F16),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _bukaDetail(item),
                                  child: const Text("Beli",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13)),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  onPressed: null,
                                  child: const Text("Habis",
                                      style:
                                          TextStyle(color: Colors.grey)),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _bukaDetail(dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetailScreen(product: Map<String, dynamic>.from(item)),
      ),
    );
  }

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final double nilai = double.tryParse(harga.toString()) ?? 0;
    return nilai
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
import 'package:flutter/material.dart';
import 'product_edit_page.dart';
import 'product_create_page.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetsadmin/product_card.dart';
import 'package:flutter_application_mbahmeth/models/modelsadmin/product_model.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';

class ProductListPage extends StatefulWidget {
  final bool isEmbedded;

  const ProductListPage({super.key, this.isEmbedded = false});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with SingleTickerProviderStateMixin {
  static const _primaryGreen     = Color(0xFF2E9900);
  static const _primaryGreenDark = Color(0xFF1F6B00);
  static const _backgroundLight  = Color(0xFFF4FAF2);
  static const _backgroundWhite  = Color(0xFFFFFFFF);
  static const _textDark         = Color(0xFF1A2E1A);
  static const _textLight        = Color(0xFF8A9E8A);
  static const _textHint         = Color(0xFFB0C4B0);
  static const _primaryRed       = Color(0xFFD32F2F);

  final ApiService _service = ApiService();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = "";
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _applyFilter();
      }
    });

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAdminProducts();
      setState(() {
        _allProducts = data;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    List<ProductModel> result = _allProducts.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final int tab = _tabController.index;
    if (tab == 1) {
      // ✅ FIX: Batas stok "Menipis" diubah dari < 20 menjadi < 10
      //  SEBELUM (BUG): result = result.where((p) => p.stock > 0 && p.stock < 20).toList();
      result = result.where((p) => p.stock > 0 && p.stock < 10).toList();
    } else if (tab == 2) {
      result = result.where((p) => p.stock == 0).toList();
    }

    setState(() => _filteredProducts = result);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      body: Column(
        children: [

          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              widget.isEmbedded ? 16 : 4,
              widget.isEmbedded ? 50 : 48,
              20,
              16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryGreenDark, _primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    if (!widget.isEmbedded)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    Image.asset(
                      'assets/images/x2.png',
                      height: 38,
                      errorBuilder: (c, e, s) => Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.eco_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilter();
                    },
                    style: const TextStyle(color: _textDark, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Cari Produk",
                      hintStyle: TextStyle(color: _textHint),
                      prefixIcon: Icon(Icons.search, color: _textLight),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── TabBar ──────────────────────────────────────────────────
          Container(
            color: _backgroundWhite,
            child: TabBar(
              controller: _tabController,
              labelColor: _primaryGreen,
              unselectedLabelColor: _textLight,
              indicatorColor: _primaryGreen,
              indicatorWeight: 3,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(text: "Semua"),
                // ✅ FIX: Label tab diperbarui agar mencerminkan batas baru (< 10)
                Tab(text: "Menipis (< 10)"),
                Tab(text: "Habis"),
              ],
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryGreen))
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.inventory_2_outlined,
                                  size: 36, color: _textLight),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "Tidak ada data produk",
                              style: TextStyle(color: _textLight),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _loadData,
                              style: TextButton.styleFrom(
                                  foregroundColor: _primaryGreen),
                              child: const Text("Refresh"),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: _primaryGreen,
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final produk = _filteredProducts[index];
                            return ProductCard(
                              name: produk.name,
                              price: "Rp. ${produk.price}",
                              stock: produk.stock,
                              imageUrl:
                                  "${ApiService.imageUrl}${produk.imagePath}",

                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductEditPage(product: produk),
                                  ),
                                ).then((value) {
                                  if (value == true) _loadData();
                                });
                              },

                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    backgroundColor: _backgroundWhite,
                                    title: const Text("Hapus Produk",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _textDark)),
                                    content: const Text(
                                      "Apakah Anda yakin ingin menghapus produk ini?",
                                      style: TextStyle(color: _textLight),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text("Batal",
                                            style: TextStyle(
                                                color: _textLight)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          bool success =
                                              await ApiService().deleteProduct(
                                                  produk.id.toString());
                                          if (success) {
                                            _loadData();
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                      "Produk berhasil dihapus"),
                                                  backgroundColor:
                                                      _primaryGreen,
                                                  behavior: SnackBarBehavior
                                                      .floating,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12)),
                                                ),
                                              );
                                            }
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                      "Gagal menghapus produk"),
                                                  backgroundColor: _primaryRed,
                                                  behavior: SnackBarBehavior
                                                      .floating,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12)),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _primaryRed,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        child: const Text("Hapus",
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryGreen,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ProductCreatePage()),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
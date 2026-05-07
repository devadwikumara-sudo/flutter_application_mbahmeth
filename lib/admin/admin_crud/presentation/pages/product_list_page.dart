import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/admin/admin_crud/presentation/pages/product_edit_page.dart';
import 'package:flutter_application_mbahmeth/models/modelsadmin/product_model.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetsadmin/product_card.dart';
import '../widgets/widgetsadmin/product_card.dart';
import '../../data/product_service.dart';
import 'package:flutter_application_mbahmeth/admin/admin_crud/models/modelsadmin/product_model.dart';
import 'product_create_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  //ganti ip setiap ganti wifi
  final String imageServerBase = "http://172.16.103.136/api_pertanian/uploads/";

  // Kontrol untuk Search & Filter
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = "";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadData();
  }

  // Fungsi ambil data dari database
  Future<void> _loadData() async {
    final data = await _productService.getProducts();
    setState(() {
      _allProducts = data;
      _applyFilter();
    });
  }

  // Logika Filter: Gabungan Search & Tab
  void _applyFilter() {
    setState(() {
      // 1. Filter berdasarkan Search
      _filteredProducts = _allProducts
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();

      // 2. Filter berdasarkan Tab Status
      if (_tabController.index == 1) {
        // Stok Menipis (Misal: < 20 dan > 0)
        _filteredProducts = _filteredProducts
            .where((p) => p.stock > 0 && p.stock < 20)
            .toList();
      } else if (_tabController.index == 2) {
        // Stok Habis (0)
        _filteredProducts = _filteredProducts
            .where((p) => p.stock == 0)
            .toList();
      }
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E9900);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- HEADER & SEARCH AREA ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            color: primaryGreen,
            child: Column(
              children: [
                // Logo & Nama 
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Image.asset(
                        'assets/images/logo_MbahMeth.png',
                        height: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "MbahMeth",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "Portal Admin",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilter();
                    },
                    decoration: const InputDecoration(
                      hintText: "Cari Produk",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- TAB FILTER ---
          TabBar(
            controller: _tabController,
            labelColor: primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryGreen,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Semua Produk"),
              Tab(text: "Stok Menipis"),
              Tab(text: "Stok Habis"),
            ],
          ),

          // --- LIST PRODUK ---
          Expanded(
            child: _allProducts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final produk = _filteredProducts[index];
                        return ProductCard(
                          name: produk.name,
                          price: "Rp ${produk.price}",
                          stock: produk.stock,
                          imageUrl: "$imageServerBase${produk.imagePath}",
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductEditPage(product: produk),
                              ),
                            ).then((value) {
                              // Jika value true, berarti ada perubahan, maka refresh data
                              if (value == true) {
                                _loadData();
                              }
                            });
                          },
                          onDelete: () {},
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      // Floating Action Button Tambah (Hijau)
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductCreatePage()),
        ).then((_) => _loadData()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

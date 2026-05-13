import 'package:flutter/material.dart';

import 'product_edit_page.dart';
import 'product_create_page.dart';

import 'package:flutter_application_mbahmeth/widgets/widgetsadmin/product_card.dart';
import 'package:flutter_application_mbahmeth/models/modelsadmin/product_model.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with SingleTickerProviderStateMixin {

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

    _tabController.addListener(_handleTabSelection);

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _service.getAdminProducts();

      setState(() {
        _allProducts = data;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load data: $e");

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    _filteredProducts = _allProducts.where((p) {
      return p.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();

    // TAB FILTER
    if (_tabController.index == 1) {
      // stok menipis
      _filteredProducts = _filteredProducts.where((p) {
        return p.stock > 0 && p.stock < 20;
      }).toList();
    } else if (_tabController.index == 2) {
      // stok habis
      _filteredProducts = _filteredProducts.where((p) {
        return p.stock == 0;
      }).toList();
    }

    setState(() {});
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _applyFilter();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const primaryGreen = Color(0xFF2E9900);

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            color: primaryGreen,

            child: Column(
              children: [

                Row(
                  children: [

                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,

                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 25,

                        errorBuilder: (c, e, s) {
                          return const Icon(Icons.shop);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

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
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

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
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TABBAR
          TabBar(
            controller: _tabController,
            labelColor: primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryGreen,

            tabs: const [
              Tab(text: "Semua"),
              Tab(text: "Menipis"),
              Tab(text: "Habis"),
            ],
          ),

          // CONTENT
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                    ),
                  )

                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            const Text(
                              "Tidak ada data produk",
                            ),

                            TextButton(
                              onPressed: _loadData,
                              child: const Text("Refresh"),
                            ),
                          ],
                        ),
                      )

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

                              imageUrl:
                                  "${ApiService.imageUrl}${produk.imagePath}",

                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ProductEditPage(
                                        product: produk,
                                      );
                                    },
                                  ),
                                ).then((value) {
                                  if (value == true) {
                                    _loadData();
                                  }
                                });
                              },

                              onDelete: () {
                                showDialog(
                                  context: context,

                                  builder: (context) {
                                    return AlertDialog(

                                      title: const Text(
                                        "Hapus Produk",
                                      ),

                                      content: const Text(
                                        "Apakah Anda yakin ingin menghapus produk ini?",
                                      ),

                                      actions: [

                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },

                                          child: const Text("Batal"),
                                        ),

                                        TextButton(
                                          onPressed: () async {

                                            Navigator.pop(context);

                                            bool success =
                                                await ApiService()
                                                    .deleteProduct(
                                              produk.id.toString(),
                                            );

                                            if (success) {

                                              _loadData();

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Produk berhasil dihapus",
                                                  ),
                                                ),
                                              );

                                            } else {

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Gagal menghapus produk",
                                                  ),
                                                ),
                                              );
                                            }
                                          },

                                          child: const Text(
                                            "Hapus",
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
        backgroundColor: primaryGreen,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const ProductCreatePage();
              },
            ),
          ).then((_) {
            _loadData();
          });
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
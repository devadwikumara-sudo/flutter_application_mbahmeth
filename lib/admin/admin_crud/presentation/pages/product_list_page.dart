import 'package:flutter/material.dart';
// Karena berada di folder yang sama, cukup panggil nama filenya
import 'product_create_page.dart';
import 'product_edit_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String _selectedTab = "Semua Produk";

  // Data dummy produk
  final List<Map<String, dynamic>> _allProducts = [
    {"name": "Arjuna 200 EC", "price": "26.000", "stock": 45, "status": "aman"},
    {"name": "Pupuk KNO Merah", "price": "28.000", "stock": 12, "status": "menipis"},
    {"name": "Pupuk KNO Putih", "price": "28.000", "stock": 0, "status": "habis"},
    {"name": "Jagung Perkasa", "price": "28.000", "stock": 28, "status": "aman"},
    {"name": "Ciherang", "price": "26.000", "stock": 18, "status": "aman"},
  ];

  @override
  Widget build(BuildContext context) {
    // Logika untuk menyaring produk berdasarkan tab
    List<Map<String, dynamic>> filteredProducts = _allProducts.where((product) {
      if (_selectedTab == "Stok Menipis") return product['status'] == "menipis";
      if (_selectedTab == "Stok Habis") return product['status'] == "habis";
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. TOMBOL (+) CREATE YANG BISA DIPENCET
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductCreatePage()),
          );
        },
        backgroundColor: const Color(0xFF2E9900),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF2E9900),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.eco, color: Color(0xFF2E9900)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("MbahMeth", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("Portal Admin", 
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari Produk",
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
          
          // TAB FILTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTab("Semua Produk"),
              _buildTab("Stok Menipis"),
              _buildTab("Stok Habis"),
            ],
          ),
          const Divider(thickness: 1),

          // LIST PRODUK
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                var p = filteredProducts[index];
                return _buildProductItem(
                  p['name'], 
                  p['price'], 
                  "${p['stock']} unit", 
                  p['status'] == "habis" ? Colors.red : (p['status'] == "menipis" ? Colors.orange : Colors.green)
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET TAB
  Widget _buildTab(String label) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label, 
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.grey, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              )
            ),
          ),
          if (isSelected) Container(height: 3, width: 40, color: Colors.green)
          else const SizedBox(height: 3),
        ],
      ),
    );
  }

  // WIDGET ITEM PRODUK
  Widget _buildProductItem(String name, String price, String stock, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 70, height: 70, color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("Rp $price", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: themeColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text("Stok: $stock", style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // 2. TOMBOL EDIT (PENSIL) YANG BISA DIPENCET
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductEditPage(product: {},)),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.green, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          
          // TOMBOL HAPUS (Belum ada fungsinya)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  // Ganti IP_LAPTOP dengan IP Anda (cek di CMD: ipconfig)
  final String baseUrl = "http://192.168.0.51/toko_mbahmeth/api";
  final String imageUrl = "http://192.168.0.51/toko_mbahmeth/assets/images/";

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_products.php?id_category=${widget.idCategory}"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat produk');
      }
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Produk tidak ditemukan"));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              final int stok = int.parse(item['stok'].toString());

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(product: item),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          image: DecorationImage(
                            // Mengambil gambar dari folder assets di Laragon
                            image: NetworkImage('$imageUrl${item['gambar']}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama_produk'] ?? item['nama'], // Sesuaikan nama kolom DB
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Rp ${item['harga']}",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          
                          // Logika Tombol Sesuai Stok
                          SizedBox(
                            width: double.infinity,
                            child: stok > 0
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () {
                                      // Logika tambah ke keranjang
                                    },
                                    child: const Text("Beli", style: TextStyle(color: Colors.white)),
                                  )
                                : const ElevatedButton(
                                    onPressed: null,
                                    child: Text("Habis"),
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
          );
        },
      ),
    );
  }
}
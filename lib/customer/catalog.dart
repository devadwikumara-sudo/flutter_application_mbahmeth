import 'package:flutter/material.dart';

class CatalogScreen extends StatelessWidget {
  final String categoryName;
  // Contoh data dummy (nanti diganti dari API Laragon)
  final List<Map<String, dynamic>> products = List.generate(10, (index) => {
    "nama": "Insektisida Arjuna 200 EC",
    "harga": 28000,
    "stok": index % 3 == 0 ? 0 : 10, // Simulasi stok habis
    "gambar": "arjuna.jpg"
  });

  CatalogScreen({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName), backgroundColor: Colors.green),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      image: DecorationImage(
                        image: AssetImage('assets/images/${item['gambar']}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['nama'], style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Rp ${item['harga']}", style: TextStyle(color: Colors.green)),
                      SizedBox(height: 5),
                      // Logika Tombol Sesuai Stok
                      item['stok'] > 0 
                        ? ElevatedButton(onPressed: () {}, child: Text("Beli"))
                        : ElevatedButton(onPressed: null, child: Text("Habis")),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
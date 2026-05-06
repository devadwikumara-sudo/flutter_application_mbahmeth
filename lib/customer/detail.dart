import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan folder di Screenshot 2026-04-30 220140.png
import 'package:flutter_application_mbahmeth/services/api_service.dart'; 

class DetailScreen extends StatefulWidget {
  // Tambahkan constructor untuk menerima data produk dari Catalog
  final Map<String, dynamic> product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int jumlah = 1;
  late int stokMax;
  // Inisialisasi ApiService agar bisa digunakan di tombol
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Mengambil stok asli dari data produk database
    stokMax = int.parse(widget.product['stok'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Produk")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar Produk dari URL Laragon[cite: 1, 3]
            Image.network(
              "http://192.168.1.4/toko_mbahmeth/assets/images/${widget.product['gambar']}",
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nama Produk dinamis
                      Expanded(
                        child: Text(
                          widget.product['nama_produk'].toString(),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Harga Produk dinamis[cite: 1]
                      Text(
                        "Rp ${widget.product['harga']}",
                        style: const TextStyle(fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
                  // Deskripsi dinamis[cite: 1]
                  Text(widget.product['deskripsi'].toString()),
                  const SizedBox(height: 30),
                  
                  // Counter Jumlah
                  Row(
                    children: [
                      const Text("Jumlah"),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => jumlah > 1 ? jumlah-- : null), 
                        icon: const Icon(Icons.remove_circle_outline)
                      ),
                      Text("$jumlah"),
                      IconButton(
                        onPressed: () => setState(() => jumlah < stokMax ? jumlah++ : null), 
                        icon: const Icon(Icons.add_circle_outline)
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Tombol Keranjang
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: stokMax > 0 ? () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        bool success = await apiService.addToCart(
                          userId: 1, // Sementara manual ID 1
                          productId: int.parse(widget.product['id'].toString()), 
                          jumlah: jumlah
                        );
                        
                        if (success) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text("Berhasil masuk keranjang!"),
                              backgroundColor: Colors.green,
                            )
                          );
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text("Gagal masuk keranjang"),
                              backgroundColor: Colors.red,
                            )
                          );
                        }
                      } : null, 
                      child: Text(
                        stokMax > 0 ? "Masukkan Keranjang" : "Stok Habis",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
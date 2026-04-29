import 'package:flutter/material.dart';

class ProductEditPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductEditPage({super.key, required this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Color primaryGreen = const Color(0xFF2E9900); // Hijau Figma
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController categoryController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    // Mengisi controller dengan data dummy agar mode EDIT terisi otomatis
    nameController = TextEditingController(text: widget.product['name']);
    priceController = TextEditingController(text: widget.product['price']);
    stockController = TextEditingController(text: widget.product['stock'].toString());
    categoryController = TextEditingController(text: widget.product['category']);
    descController = TextEditingController(text: widget.product['description']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text('Edit Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("NAMA PRODUK"),
            _buildTextField(nameController, "Nama Produk"),

            const SizedBox(height: 20),
            _buildLabel("HARGA"),
            _buildTextField(priceController, "26.000"),

            const SizedBox(height: 20),
            _buildLabel("JUMLAH PRODUK"),
            _buildTextField(stockController, "45"),

            const SizedBox(height: 20),
            _buildLabel("KATEGORI"),
            _buildTextField(categoryController, "Obat Pertanian"),

            const SizedBox(height: 20),
            _buildLabel("DESCRIPTION"),
            _buildTextField(descController, "Deskripsi produk", maxLines: 5),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Simpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk Label (Teks hijau kecil di atas field)
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // Widget helper untuk TextField agar tampilannya seragam sesuai Figma
  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFBFBFB), // Putih sedikit abu
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}

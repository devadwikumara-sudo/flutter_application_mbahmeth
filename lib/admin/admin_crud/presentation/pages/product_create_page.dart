import 'package:flutter/material.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final Color primaryGreen = const Color(0xFF2E9900); // Hijau Figma

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang abu-abu sangat muda
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            const Text("Foto Produk", style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 8),
            
            // AREA FOTO PRODUK (Menggunakan Placeholder Warna)
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.05), // Latar belakang hijau sangat muda
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryGreen.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: primaryGreen, size: 40),
                  const SizedBox(height: 8),
                  Text("Tambah Foto Produk", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildLabel("Nama Produk"),
            _buildTextField("Contoh: Pupuk Organik Cair"),

            const SizedBox(height: 20),
            // Dua Field dalam satu baris (Harga & Stok)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Harga (Rp)"),
                      _buildTextField("0"),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Jumlah Stok"),
                      _buildTextField("0"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildLabel("Kategori"),
            _buildDropdownField("Pilih Kategori"),

            const SizedBox(height: 20),
            _buildLabel("Deskripsi Produk"),
            _buildTextField("Jelaskan detail produk Anda di sini...", maxLines: 4),

            const SizedBox(height: 40),
            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text('Simpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  // Helper khusus untuk Dropdown (gaya Figma)
  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          isExpanded: true,
          items: <String>['Pupuk', 'Benih', 'Alat', 'Obat'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}

import 'package:crud_filter/features/admin_crud/data/product_service.dart';
import 'package:crud_filter/features/admin_crud/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/admin/admin_crud/data/product_service.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final Color primaryGreen = const Color(0xFF2E9900);

  // Controller untuk input teks
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(); 
  final _descController = TextEditingController();
  
  String? _selectedCategory;
  
  // Variabel untuk menampung file gambar yang dipilih
  XFile? _selectedImage; 
  final ImagePicker _picker = ImagePicker();

  //  Membuka File Explorer untuk pilih gambar
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery, // Membuka folder di laptop/PC
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _saveData() async {
    // Validasi: Pastikan field penting dan GAMBAR sudah dipilih
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, Harga, dan Foto wajib diisi!")),
      );
      return;
    }

    // 1. Bungkus data ke dalam Model
    final newProduct = ProductModel(
      name: _nameController.text,
      price: int.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      description: _descController.text,
      category: _selectedCategory,
      imagePath: _selectedImage!.name, // Mengambil nama asli file (misal: pupuk.jpg)
    );

    // 2. Kirim data dan file ke ProductService
    // Pastikan kamu sudah mengupdate fungsi addProduct di product_service.dart
    bool success = await ProductService().addProduct(newProduct, _selectedImage);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk Berhasil Ditambah!")),
        );
        Navigator.pop(context); 
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan ke database!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text('Tambah Produk Baru', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            _buildLabel("Foto Produk"),
            const SizedBox(height: 8),
            
            // AREA PILIH FOTO
            GestureDetector(
              onTap: _pickImage, // Klik untuk pilih file beneran
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryGreen.withOpacity(0.1)),
                ),
                child: _selectedImage == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: primaryGreen, size: 40),
                        const SizedBox(height: 8),
                        Text("Tap untuk unggah foto", 
                          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                        const Text("Format: JPG/PNG (Max 2MB)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network( // Preview gambar di Web
                        _selectedImage!.path,
                        fit: BoxFit.cover,
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 20),
            _buildLabel("Nama Produk"),
            _buildTextField("Contoh: Pupuk Organik Cair", _nameController),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Harga (Rp)"),
                      _buildTextField("0", _priceController, isNumber: true),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Jumlah Stok"),
                      _buildTextField("0", _stockController, isNumber: true),
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
            _buildTextField("Jelaskan detail produk...", _descController, maxLines: 4),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveData,
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text('Simpan Produk', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // --- WIDGET HELPER ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: Text(hint),
          isExpanded: true,
          items: <String>['Pupuk', 'Benih', 'Alat', 'Obat'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedCategory = newValue),
        ),
      ),
    );
  }
}
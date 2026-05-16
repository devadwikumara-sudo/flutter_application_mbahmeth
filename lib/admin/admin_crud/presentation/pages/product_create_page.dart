import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_mbahmeth/models/modelsadmin/product_model.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';

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
  XFile? _selectedImage;
  Uint8List? _webImage; // Khusus preview di Flutter Web
  final ImagePicker _picker = ImagePicker();

  // Membuka File Explorer/Gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      if (kIsWeb) {
        // Baca bytes agar bisa tampil di browser
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = image;
        });
      } else {
        setState(() {
          _selectedImage = image;
        });
      }
    }
  }

  void _saveData() async {
    // Validasi input
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, Harga, dan Foto wajib diisi!")),
      );
      return;
    }

    // Tampilkan Loading Overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 1. Bungkus data ke dalam Model
    final newProduct = ProductModel(
      name: _nameController.text,
      price: int.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      description: _descController.text,
      category: _selectedCategory,
      imagePath: _selectedImage!.name, 
    );

    // 2. Kirim ke ApiService
    bool success = await ApiService().addProduct(
      newProduct,
      _selectedImage,
    );

    if (mounted) Navigator.pop(context); // Tutup loading

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk Berhasil Ditambah!")),
        );
        Navigator.pop(context, true); // Kembali ke list & refresh
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan ke database!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          'Tambah Produk Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: primaryGreen, size: 40),
                          const SizedBox(height: 8),
                          Text("Pilih Gambar", style: TextStyle(color: primaryGreen)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: kIsWeb
                            ? Image.memory(_webImage!, fit: BoxFit.cover)
                            : Image.network(_selectedImage!.path, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 20),
            _buildLabel("Nama Produk"),
            _buildTextField("Masukkan nama produk", _nameController),

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
            _buildTextField(
              "Jelaskan detail produk...",
              _descController,
              maxLines: 4,
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _saveData,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'SIMPAN PRODUK',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
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

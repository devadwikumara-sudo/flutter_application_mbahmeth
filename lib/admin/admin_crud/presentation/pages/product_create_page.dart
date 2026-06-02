import 'package:flutter/foundation.dart';
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
  static const _primaryGreen     = Color(0xFF2E9900);
  static const _primaryGreenDark = Color(0xFF1F6B00);
  static const _backgroundLight  = Color(0xFFF4FAF2);
  static const _backgroundWhite  = Color(0xFFFFFFFF);
  static const _textDark         = Color(0xFF1A2E1A);
  static const _textHint         = Color(0xFFB0C4B0);
  static const _inputBorder      = Color(0xFFDFEFDF);
  static const _successLight     = Color(0xFFE8F5E2);
  static const _primaryRed       = Color(0xFFD32F2F);

  final _nameController  = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController  = TextEditingController();

  String? _selectedCategory;
  XFile? _selectedImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _categoryMapping = {
    'Obat'  : '1',
    'Pupuk' : '2',
    'Benih' : '3',
    'Alat'  : '4',
  };

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = image;
        });
      } else {
        setState(() => _selectedImage = image);
      }
    }
  }

  void _saveData() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Nama, Harga, dan Foto wajib diisi!"),
          backgroundColor: _primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final String selectedId = _categoryMapping[_selectedCategory] ?? '1';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: _primaryGreen)),
    );

    final newProduct = ProductModel(
      name: _nameController.text,
      price: int.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      description: _descController.text,
      category: selectedId,
      imagePath: _selectedImage!.name,
    );

    bool success = await ApiService().addProduct(newProduct, _selectedImage);
    if (mounted) Navigator.pop(context);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Produk Berhasil Ditambah!"),
            backgroundColor: _primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal menyimpan ke database!"),
            backgroundColor: _primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(4, 48, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryGreenDark, _primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset(
                  'assets/images/x2.png',
                  height: 38,
                  errorBuilder: (c, e, s) => Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Tambah Produk",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Foto Produk", Icons.image_outlined),
                  const SizedBox(height: 10),

                  // ── Area pilih foto ──────────────────────────────────
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: _backgroundWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _inputBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E9900).withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: _successLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_a_photo_outlined,
                                      color: _primaryGreen, size: 32),
                                ),
                                const SizedBox(height: 10),
                                const Text("Ketuk untuk pilih gambar",
                                    style: TextStyle(
                                        color: _primaryGreen,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                const Text("JPG, PNG, WEBP",
                                    style: TextStyle(
                                        color: _textHint, fontSize: 12)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: kIsWeb
                                  ? Image.memory(_webImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity)
                                  : Image.network(_selectedImage!.path,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionLabel("Nama Produk", Icons.local_florist_outlined),
                  const SizedBox(height: 8),
                  _buildTextField("Masukkan nama produk", _nameController),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel("Harga (Rp)", Icons.payments_outlined),
                            const SizedBox(height: 8),
                            _buildTextField("0", _priceController, isNumber: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel("Stok", Icons.inventory_2_outlined),
                            const SizedBox(height: 8),
                            _buildTextField("0", _stockController, isNumber: true),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildSectionLabel("Kategori", Icons.category_outlined),
                  const SizedBox(height: 8),
                  _buildDropdownField("Pilih Kategori"),

                  const SizedBox(height: 20),
                  _buildSectionLabel("Deskripsi Produk", Icons.description_outlined),
                  const SizedBox(height: 8),
                  _buildTextField("Jelaskan detail produk...", _descController,
                      maxLines: 4),

                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saveData,
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      label: const Text(
                        'SIMPAN PRODUK',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _primaryGreen),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _textDark)),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: _textDark, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textHint),
        filled: true,
        fillColor: _backgroundWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: Text(hint, style: const TextStyle(color: _textHint)),
          isExpanded: true,
          style: const TextStyle(color: _textDark, fontSize: 14),
          dropdownColor: _backgroundWhite,
          // Urutan dropdown selaras dengan ID database
          items: <String>['Obat', 'Pupuk', 'Benih', 'Alat'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedCategory = newValue),
        ),
      ),
    );
  }
}
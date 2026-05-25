import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/models/modelsadmin/product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';

class ProductEditPage extends StatefulWidget {
  final ProductModel product;

  const ProductEditPage({super.key, required this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  static const _primaryGreen     = Color(0xFF2E9900);
  static const _primaryGreenDark = Color(0xFF1F6B00);
  static const _backgroundLight  = Color(0xFFF4FAF2);
  static const _backgroundWhite  = Color(0xFFFFFFFF);
  static const _textDark         = Color(0xFF1A2E1A);
  static const _textLight        = Color(0xFF8A9E8A);
  static const _textHint         = Color(0xFFB0C4B0);
  static const _inputBorder      = Color(0xFFDFEFDF);
  static const _successLight     = Color(0xFFE8F5E2);
  static const _primaryRed       = Color(0xFFD32F2F);

  // ✅ FIX: Mapping kategori diurutkan sesuai ID di database (1=Obat, 2=Pupuk, 3=Benih, 4=Alat)
  //         dan konsisten dengan product_create_page.dart
  final Map<String, String> categoryMapping = {
    'Obat'  : '1',
    'Pupuk' : '2',
    'Benih' : '3',
    'Alat'  : '4',
  };

  final Map<String, String> categoryIdToName = {
    '1': 'Obat',
    '2': 'Pupuk',
    '3': 'Benih',
    '4': 'Alat',
  };

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController descController;

  String? _selectedCategory;
  XFile? _newImageFile;
  final ImagePicker _picker = ImagePicker();

  // ✅ FIX: Hapus imageServerBase yang hardcoded ke IP berbeda.
  //         Gunakan AppConfig.imageServerUrl sebagai satu-satunya sumber kebenaran.
  //  SEBELUM (BUG): final String imageServerBase = "http://172.16.103.30/toko_mbahmeth/public/assets/products/";
  //  SESUDAH (FIX): pakai AppConfig.imageServerUrl di build()

  @override
  void initState() {
    super.initState();
    nameController  = TextEditingController(text: widget.product.name);
    priceController = TextEditingController(text: widget.product.price.toString());
    stockController = TextEditingController(text: widget.product.stock.toString());
    descController  = TextEditingController(text: widget.product.description);

    final raw = widget.product.category ?? '';
    if (categoryMapping.containsKey(raw)) {
      _selectedCategory = raw;
    } else if (categoryIdToName.containsKey(raw)) {
      _selectedCategory = categoryIdToName[raw];
    } else {
      _selectedCategory = null;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _newImageFile = image);
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
                  "Edit Produk",
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
                  // ── Preview & Ganti Foto ─────────────────────────────
                  _buildSectionLabel("FOTO PRODUK", Icons.image_outlined),
                  const SizedBox(height: 10),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _newImageFile != null
                            ? Image.network(_newImageFile!.path, fit: BoxFit.cover)
                            : Image.network(
                                // ✅ FIX: Gunakan AppConfig.imageServerUrl bukan IP hardcoded
                                "${AppConfig.imageServerUrl}${widget.product.imagePath}",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                              color: _successLight,
                                              shape: BoxShape.circle),
                                          child: const Icon(
                                              Icons.image_not_supported_outlined,
                                              size: 32,
                                              color: _textLight),
                                        ),
                                      ],
                                    ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.touch_app_rounded, size: 13, color: _textLight),
                      SizedBox(width: 4),
                      Text(
                        "Ketuk gambar untuk mengganti foto",
                        style: TextStyle(fontSize: 12, color: _textLight),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Input Fields ─────────────────────────────────────
                  _buildSectionLabel("NAMA PRODUK", Icons.local_florist_outlined),
                  const SizedBox(height: 8),
                  _buildTextField(nameController, "Masukkan Nama Produk"),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel("HARGA (Rp)", Icons.payments_outlined),
                            const SizedBox(height: 8),
                            _buildTextField(priceController, "Contoh: 25000", isNumber: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel("STOK", Icons.inventory_2_outlined),
                            const SizedBox(height: 8),
                            _buildTextField(stockController, "Contoh: 10", isNumber: true),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildSectionLabel("KATEGORI", Icons.category_outlined),
                  const SizedBox(height: 8),
                  _buildDropdownField("Pilih Kategori"),

                  const SizedBox(height: 20),
                  _buildSectionLabel("DESKRIPSI", Icons.description_outlined),
                  const SizedBox(height: 8),
                  _buildTextField(descController, "Deskripsi lengkap produk...", maxLines: 4),

                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final String categoryId;
                        if (_selectedCategory != null) {
                          categoryId = categoryMapping[_selectedCategory] ??
                              widget.product.category ?? '1';
                        } else {
                          categoryId = widget.product.category ?? '1';
                        }

                        final updatedData = ProductModel(
                          id: widget.product.id,
                          name: nameController.text,
                          price: int.tryParse(priceController.text) ?? 0,
                          stock: int.tryParse(stockController.text) ?? 0,
                          category: categoryId,
                          description: descController.text,
                          imagePath: widget.product.imagePath,
                        );

                        bool success = await ApiService()
                            .updateProduct(updatedData, _newImageFile);

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Produk berhasil diperbarui!"),
                              backgroundColor: _primaryGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          Navigator.pop(context, true);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text("Gagal memperbarui produk!"),
                                backgroundColor: _primaryRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      label: const Text(
                        'Simpan Perubahan',
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
        Icon(icon, size: 14, color: _primaryGreen),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
              color: _primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
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
          // ✅ FIX: Urutan dropdown diselaraskan dengan ID database (1=Obat, 2=Pupuk, 3=Benih, 4=Alat)
          items: <String>['Obat', 'Pupuk', 'Benih', 'Alat'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedCategory = newValue),
        ),
      ),
    );
  }
}
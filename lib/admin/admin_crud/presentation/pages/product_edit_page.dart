import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/product_service.dart';
import 'package:flutter_application_mbahmeth/models/modelsadmin/product_model.dart';
class ProductEditPage extends StatefulWidget {
  final ProductModel product;

  const ProductEditPage({super.key, required this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Color primaryGreen = const Color(0xFF2E9900);
  
  // Controller untuk input teks
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController categoryController;
  late TextEditingController descController;

  // Variabel untuk menangani perubahan foto
  XFile? _newImageFile; 
  final ImagePicker _picker = ImagePicker();
  //ganti ip setiap ganti wifi
  final String imageServerBase = "http://172.16.115.174/api_pertanian/uploads/";

  @override
  void initState() {
    super.initState();
    // Mengisi data awal dari objek product yang dikirim
    nameController = TextEditingController(text: widget.product.name);
    priceController = TextEditingController(text: widget.product.price.toString());
    stockController = TextEditingController(text: widget.product.stock.toString());
    categoryController = TextEditingController(text: widget.product.category);
    descController = TextEditingController(text: widget.product.description);
  }

  // Fungsi untuk memilih gambar baru dari galeri
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newImageFile = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text('Edit Produk', 
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
            // --- BAGIAN PREVIEW & GANTI FOTO ---
            _buildLabel("FOTO PRODUK"),
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _newImageFile != null
                        ? Image.network(_newImageFile!.path, fit: BoxFit.cover) // Foto baru yang dipilih
                        : Image.network(
                            "$imageServerBase${widget.product.imagePath}", // Foto lama dari server
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text("Ketuk gambar untuk mengganti foto", 
              style: TextStyle(fontSize: 12, color: Colors.grey))),

            const SizedBox(height: 25),
            
            // --- INPUT FIELDS ---
            _buildLabel("NAMA PRODUK"),
            _buildTextField(nameController, "Masukkan Nama Produk"),

            const SizedBox(height: 20),
            _buildLabel("HARGA (Rp)"),
            _buildTextField(priceController, "Contoh: 25000", isNumber: true),

            const SizedBox(height: 20),
            _buildLabel("JUMLAH STOK"),
            _buildTextField(stockController, "Contoh: 10", isNumber: true),

            const SizedBox(height: 20),
            _buildLabel("KATEGORI"),
            _buildTextField(categoryController, "Obat/Pupuk/Alat"),

            const SizedBox(height: 20),
            _buildLabel("DESKRIPSI"),
            _buildTextField(descController, "Deskripsi lengkap produk...", maxLines: 4),

            const SizedBox(height: 40),
            
            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  // 1. Siapkan objek produk yang sudah diupdate
                  final updatedData = ProductModel(
                    id: widget.product.id,
                    name: nameController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    stock: int.tryParse(stockController.text) ?? 0,
                    category: categoryController.text,
                    description: descController.text,
                    imagePath: widget.product.imagePath, // Tetap kirim path lama sebagai cadangan
                  );

                  // 2. Panggil service dengan DUA PARAMETER
                  // _newImageFile akan bernilai null jika user tidak memilih foto baru
                  bool success = await ProductService().updateProduct(updatedData, _newImageFile);

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Produk berhasil diperbarui!")),
                    );
                    Navigator.pop(context, true); // Kembali dan beri sinyal sukses
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal memperbarui produk!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Perubahan', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFBFBFB),
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
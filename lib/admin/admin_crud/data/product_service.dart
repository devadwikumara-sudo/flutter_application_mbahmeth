
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/product_model.dart'; // Import dari folder models yang baru

class ProductService {
  // Ganti dengan IP Laptop Anda agar bisa diakses HP/Emulator
  static const String baseUrl = "http://192.168.1.XX/nama_proyek/api"; 

  Future<List<ProductModel>> getProductsByCategory(int idCat) async {
    final response = await http.get(Uri.parse('$baseUrl/get_products.php?id=$idCat'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }
}
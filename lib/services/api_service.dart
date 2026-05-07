import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti IP_LAPTOP dengan IP asli Anda (cek via cmd: ipconfig)
  static const String baseUrl = "http://172.16.115.174/toko_mbahmeth/api";


  // 1. Fungsi Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server Error'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 2. Fungsi Ambil Produk Berdasarkan Kategori
  Future<List<dynamic>> getProducts(int idCategory) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_products.php?id_category=$idCategory"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengambil data produk');
      }
    } catch (e) {
      throw Exception('Kesalahan Koneksi: $e');
    }
  }

  // 3. Fungsi Tambah ke Keranjang
  Future<bool> addToCart({
    required int userId, 
    required int productId, 
    required int jumlah
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_to_cart.php"),
        body: {
          'user_id': userId.toString(),
          'product_id': productId.toString(),
          'jumlah': jumlah.toString(),
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error addToCart: $e");
      return false;
    }
  }

  // 4. Fungsi Ambil Isi Keranjang (Untuk Cart Page)[cite: 1]
  Future<List<dynamic>> getCart(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_cart.php?user_id=$userId"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil keranjang');
    }
  }
}
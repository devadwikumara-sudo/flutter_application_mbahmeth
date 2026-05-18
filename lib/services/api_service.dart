import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';
import '../models/modelsadmin/product_model.dart';
import '../models/modelsadmin/order_model.dart';

class ApiService {
  static const String adminUrl = "${AppConfig.baseUrl}/admin";
  static const String customerUrl = "${AppConfig.baseUrl}/customer";
  static const String imageUrl = AppConfig.imageServerUrl;

  // ── 1. Login ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$customerUrl/login.php"),
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'message': 'Server Error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── 2. Ambil Produk per Kategori (Customer) ───────────────────────────────
  Future<List<dynamic>> getProducts(int idCategory) async {
    try {
      final response = await http.get(
        Uri.parse("$customerUrl/get_products.php?id_category=$idCategory"),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        return [];
      }
      throw Exception('Gagal mengambil data produk');
    } catch (e) {
      throw Exception('Kesalahan Koneksi: $e');
    }
  }

  // ── 3. Ambil Produk Terlaris untuk Halaman Beranda ─────────────────────────
  Future<List<dynamic>> getFeaturedProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$customerUrl/get_featured_products.php"),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        return [];
      }
      return [];
    } catch (e) {
      debugPrint("Error getFeaturedProducts: $e");
      return [];
    }
  }

  // ── 4. Tambah ke Keranjang ────────────────────────────────────────────────
  Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    required int jumlah,
    required double harga,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$customerUrl/add_to_cart.php"),
        body: {
          'id_user': userId.toString(),
          'id_product': productId.toString(),
          'jumlah': jumlah.toString(),
          'harga': harga.toString(),
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'status': 'error', 'message': 'Server error'};
    } catch (e) {
      debugPrint("Error addToCart: $e");
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // ── 5. Ambil Isi Keranjang ────────────────────────────────────────────────
  Future<Map<String, dynamic>> getCart(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$customerUrl/get_cart.php?id_user=$userId"),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'status': 'error', 'items': []};
    } catch (e) {
      throw Exception('Gagal mengambil keranjang: $e');
    }
  }

  // ── 6. Update Jumlah Item di Keranjang ────────────────────────────────────
  Future<bool> updateCartItem({
    required int idDetail,
    required int jumlah,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$customerUrl/update_cart_item.php"),
        body: {'id_detail': idDetail.toString(), 'jumlah': jumlah.toString()},
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error updateCartItem: $e");
      return false;
    }
  }

  // ── 7. Hapus Item dari Keranjang ──────────────────────────────────────────
  Future<bool> deleteCartItem(int idDetail) async {
    try {
      final response = await http.post(
        Uri.parse("$customerUrl/delete_cart_item.php"),
        body: {'id_detail': idDetail.toString()},
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error deleteCartItem: $e");
      return false;
    }
  }

  // ── 8. Checkout ───────────────────────────────────────────────────────────
  Future<bool> checkout({
    required int idOrder,
    required String metodePembayaran,
    required String metodeAmbil,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$customerUrl/checkout.php"),
        body: {
          'id_order': idOrder.toString(),
          'metode_pembayaran': metodePembayaran,
          'metode_ambil': metodeAmbil,
        },
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error checkout: $e");
      return false;
    }
  }

  // ── 9. Riwayat Pesanan ────────────────────────────────────────────────────
  Future<List<dynamic>> getHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$customerUrl/get_history.php?id_user=$userId"),
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }

  // ── 10. Ambil Semua Order (Keranjang & History) ───────────────────────────
  Future<List<dynamic>> getOrdersByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$customerUrl/get_orders_by_user.php?id_user=$userId"),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        return [];
      }
      return [];
    } catch (e) {
      debugPrint("Error getOrdersByUser: $e");
      throw Exception('Gagal mengambil data pesanan: $e');
    }
  }

  // ── 11. Upload Foto Profil ────────────────────────────────────────────────
  Future<String?> uploadFotoProfil({
    required int userId,
    required String filePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$customerUrl/upload_foto_profil.php"),
      );

      request.fields['id_user'] = userId.toString();
      request.files.add(
        await http.MultipartFile.fromPath('foto', filePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Upload foto status : ${response.statusCode}");
      debugPrint("Upload foto body   : ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['foto_url'] as String?;
        }
        debugPrint("Upload foto gagal: ${data['message']}");
      }
      return null;
    } catch (e) {
      debugPrint("Error uploadFotoProfil: $e");
      return null;
    }
  }

  // ===================== BAGIAN ADMIN (PRODUK) =====================

  // ── 12. Ambil Semua Produk (Admin) ────────────────────────────────────────
  Future<List<ProductModel>> getAdminProducts() async {
    try {
      final response = await http.get(Uri.parse("$adminUrl/read.php"));

      debugPrint("Fetch Produk Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => ProductModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error Fetch Produk: $e");
      return [];
    }
  }

  // ── 13. Tambah Produk Baru (Admin) ────────────────────────────────────────
  Future<bool> addProduct(ProductModel product, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$adminUrl/create.php"),
      );

      request.fields['name'] = product.name;
      request.fields['price'] = product.price.toString();
      request.fields['stock'] = product.stock.toString();
      request.fields['category'] = product.category ?? '';
      request.fields['description'] = product.description ?? '';

      if (imageFile != null) {
        Uint8List bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_file',
            bytes,
            filename: imageFile.name,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("Response simpan: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("Error addProduct: $e");
      return false;
    }
  }

  // ── 14. Update Produk (Admin) ─────────────────────────────────────────────
  Future<bool> updateProduct(ProductModel product, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$adminUrl/update.php"),
      );

      request.fields['id_product'] = product.id.toString();
      request.fields['name'] = product.name;
      request.fields['price'] = product.price.toString();
      request.fields['stock'] = product.stock.toString();
      request.fields['description'] = product.description ?? '';
      request.fields['category'] = product.category ?? '';

      if (imageFile != null) {
        Uint8List bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_file',
            bytes,
            filename: imageFile.name,
          ),
        );
      }

      var response = await http.Response.fromStream(await request.send());
      debugPrint("RESPONSE UPDATE: ${response.body}");
      return jsonDecode(response.body)['success'] == true;
    } catch (e) {
      debugPrint("ERROR CATCH UPDATE: $e");
      return false;
    }
  }

  // ── 15. Hapus Produk (Admin) ──────────────────────────────────────────────
  Future<bool> deleteProduct(String idProduct) async {
    try {
      final response = await http.post(
        Uri.parse("$adminUrl/delete.php"),
        body: {'id_product': idProduct},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Delete: $e");
      return false;
    }
  }

  // ===================== BAGIAN ADMIN (ORDERS) =====================

  // ── 16. Ambil Semua Order (Admin) ─────────────────────────────────────────
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await http.get(Uri.parse("$adminUrl/orders/read.php"));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => OrderModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error Fetch Orders: $e");
      return [];
    }
  }

  // ── 17. Ambil Order berdasarkan Status (Admin) ────────────────────────────
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse("$adminUrl/read_orders.php?status=$status"),
      );

      debugPrint("Fetch Filter Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => OrderModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error getOrdersByStatus: $e");
      return [];
    }
  }
  
  // ── 18. Ambil Data Profil Dinamis (FUNGSI BARU COCOK DENGAN PHP ANDA) ───
  Future<Map<String, dynamic>> getAdminProfil(String idUser) async {
    try {
      final response = await http.get(
        Uri.parse("$customerUrl/get_profil.php?id_user=$idUser"),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Gagal memuat data server'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
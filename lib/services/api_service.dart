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

  // 1. Login customer dan admin
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

  // 2. Ambil Produk per Kategori catalog 
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

  // 4. Tambah ke Keranjang dari detail dart
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

  // 5. Ambil Isi Keranjang 
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

  // 6. Update Jumlah Item di Keranjang 
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

  // 7. Hapus Item dari Keranjang 
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

  // 8. Checkout
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

  // 9. history 
  Future<List<dynamic>> getHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$customerUrl/get_history.php?id_user=$userId"),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        return [];
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }

  // 10. Ambil Semua Order profil customer
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

  // 11. Upload Foto Profil 
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

  // BAGIAN ADMIN 

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
      request.fields['category'] = product.category ?? '1';
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

      var response =
          await http.Response.fromStream(await request.send());
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

  // ── 18. Ambil Data Profil Admin ───────────────────────────────────────────
  Future<Map<String, dynamic>> getAdminProfil(String idUser) async {
    try {
      final url = Uri.parse("$adminUrl/get_profil.php?id_user=$idUser");
      debugPrint("Panggilan URL Profil: $url");

      final response = await http.get(url);
      debugPrint("Status Server Profil: ${response.statusCode}");
      debugPrint("Isi Response Profil: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Gagal memuat data server'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 19. Ambil Semua user
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response =
          await http.get(Uri.parse("$adminUrl/get_users.php"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'status': 'error',
        'message': 'Server error: ${response.statusCode}'
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Tidak dapat terhubung ke server.'
      };
    }
  }

  // 21. order page
  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      final response =
          await http.get(Uri.parse("$adminUrl/get_orders.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List list = data['data'];
          return list.map((e) => OrderModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error fetchAllOrders: $e");
      return [];
    }
  }

  // 22.update status pesanan di order
  Future<bool> updateOrderStatus({
    required int idOrder,
    required String status,
  }) async {
    try {
      debugPrint("updateOrderStatus → id=$idOrder status=$status");

      final response = await http.post(
        Uri.parse("$adminUrl/update_order_status.php"),
        body: {
          'id_order': idOrder.toString(),
          'status': status,
        },
      );

      debugPrint("updateOrderStatus response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error updateOrderStatus: $e");
      return false;
    }
  }

  // 23.Ambil Statistik Dashboard Admin 
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Tambahkan timestamp sebagai cache-buster agar selalu dapat data terbaru
      final ts = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse("$adminUrl/dashboard_stats.php?_t=$ts");
      debugPrint("getDashboardStats → GET $url");

      final response = await http
          .get(url, headers: {'Cache-Control': 'no-cache'})
          .timeout(const Duration(seconds: 15));

      debugPrint("getDashboardStats [${response.statusCode}]: ${response.body}");

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: Server tidak dapat diakses',
        };
      }

      // FIX: Tangkap error parsing JSON secara terpisah agar pesan lebih jelas
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        debugPrint("getDashboardStats: Response bukan JSON valid → ${response.body}");
        return {
          'success': false,
          'message': 'Response server tidak valid (bukan JSON)',
        };
      }

      if (data['success'] == true) {
        // FIX: Pastikan semua field ada agar DashboardStats.fromJson tidak crash
        return {
          'success': true,
          'total_users': data['total_users'] ?? 0,
          'total_products': data['total_products'] ?? 0,
          'total_orders': data['total_orders'] ?? 0,
          'total_revenue': data['total_revenue'] ?? 0,
        };
      }

      debugPrint("getDashboardStats server error: ${data['message']}");
      return {
        'success': false,
        'message': data['message'] ?? 'Server mengembalikan success: false',
      };
    } on Exception catch (e) {
      debugPrint("Error getDashboardStats: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  // 24. Ambil Rincian Pesanan Selesai
  Future<Map<String, dynamic>> getCompletedOrders() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final response = await http
          .get(
            Uri.parse("$adminUrl/completed_orders.php?_t=$ts"),
            headers: {'Cache-Control': 'no-cache'},
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("getCompletedOrders [${response.statusCode}]");

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) return data;
        debugPrint("getCompletedOrders server error: ${data['message']}");
      }
      return {'success': false, 'message': 'Server error: ${response.statusCode}'};
    } catch (e) {
      debugPrint("Error getCompletedOrders: $e");
      return {'success': false, 'message': e.toString()};
    }
  }
}
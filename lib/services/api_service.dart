import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/modelsadmin/product_model.dart';
import '../models/modelsadmin/order_model.dart';

class ApiService {
  // Gunakan localhost untuk testing di Chrome Web
  static const String baseUrl = "http://localhost/TOKO_MBAHMETH/api";

  // ===================== BAGIAN AUTH & CUSTOMER =====================

  // ── 1. Login ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'message': 'Server Error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── 2. Ambil Produk per Kategori ──────────────────────────────────────────
  Future<List<dynamic>> getProducts(int idCategory) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_products.php?id_category=$idCategory"),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // get_products.php mengembalikan list langsung
        if (decoded is List) return decoded;
        // Jika ternyata ada wrapper status error
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
        Uri.parse("$baseUrl/get_featured_products.php"),
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
        Uri.parse("$baseUrl/add_to_cart.php"),
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
        Uri.parse("$baseUrl/get_cart.php?id_user=$userId"),
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
        Uri.parse("$baseUrl/update_cart_item.php"),
        body: {
          'id_detail': idDetail.toString(),
          'jumlah': jumlah.toString(),
        },
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
        Uri.parse("$baseUrl/delete_cart_item.php"),
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
        Uri.parse("$baseUrl/checkout.php"),
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
        Uri.parse("$baseUrl/get_history.php?id_user=$userId"),
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }

  // ── 10. Ambil Semua Order (Keranjang & History) ──────────────────────────
  Future<List<dynamic>> getOrdersByUser(int userId) async {
    try {
      // Pastikan file php ini tersedia di backend Anda
      final response = await http.get(
        Uri.parse("$baseUrl/get_orders_by_user.php?id_user=$userId"),
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

  // ===================== BAGIAN ADMIN (PRODUK) =====================

  // Ambil semua produk (Gunakan ini di ProductListPage)
  Future<List<ProductModel>> getAdminProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/produk/read.php"));
      
      print("Fetch Produk Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => ProductModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      print("Error Fetch Produk: $e");
      return [];
    }
  }

  // Tambah produk baru (Gunakan ini di ProductCreatePage)
  Future<bool> addProduct(ProductModel product, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/produk/create.php"),
      );
      
      // Nama field ini harus sama dengan $_POST di PHP
      request.fields['name'] = product.name;
      request.fields['price'] = product.price.toString();
      request.fields['stock'] = product.stock.toString();
      request.fields['category'] = product.category ?? '';
      request.fields['description'] = product.description ?? '';

      if (imageFile != null) {
        // Handle bytes untuk Flutter Web
        Uint8List bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_file', // Harus sama dengan $_FILES['image_file'] di PHP
            bytes,
            filename: imageFile.name,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print("Response simpan: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error addProduct: $e");
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product, XFile? imageFile) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/produk/update.php"), // Pastikan ke update.php
    );

    // Kirim ID agar database tahu mana yang mau di-update
    request.fields['id_product'] = product.id.toString(); 
    request.fields['name'] = product.name;
    request.fields['price'] = product.price.toString();
    request.fields['stock'] = product.stock.toString();
    request.fields['description'] = product.description ?? '';

    if (imageFile != null) {
      Uint8List bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image_file',
        bytes,
        filename: imageFile.name,
      ));
    }

    var response = await http.Response.fromStream(await request.send());
    return jsonDecode(response.body)['success'] == true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteProduct(String idProduct) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/produk/delete.php"),
      body: {'id_product': idProduct},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['success'] == true;
    }
    return false;
  } catch (e) {
    print("Error Delete: $e");
    return false;
  }
}
  // ===================== BAGIAN ADMIN (ORDERS) =====================

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/orders/read.php"));
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => OrderModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      print("Error Fetch Orders: $e");
      return [];
    }
  }

  // Tambahkan fungsi ini di dalam class ApiService
Future<List<OrderModel>> getOrdersByStatus(String status) async {
  try {
    // Kita arahkan ke read_orders.php dengan parameter status
    final response = await http.get(
      Uri.parse("$baseUrl/read_orders.php?status=$status"),
    );

    print("Fetch Filter Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => OrderModel.fromJson(data)).toList();
    }
    return [];
  } catch (e) {
    print("Error getOrdersByStatus: $e");
    return [];
  }
}
}

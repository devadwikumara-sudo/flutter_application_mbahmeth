import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_application_mbahmeth/core/config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.authBaseUrl;
  static const String imageUrl = AppConfig.imageServerUrl;

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
}
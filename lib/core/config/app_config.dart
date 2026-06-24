import 'package:flutter/foundation.dart'; // Import kIsWeb untuk deteksi platform

class AppConfig {
  // Jika berjalan di Web (Chrome), gunakan "localhost". Jika di HP, gunakan IP lokal "192.168.1.15"
  static const String ipAddress = kIsWeb ? "localhost" : "192.168.1.15";

  // Base URL utama menuju folder 'api'
  static const String baseUrl = "http://$ipAddress/toko_mbahmeth/api";

  // Endpoint untuk masing-masing kategori
  static const String adminUrl = "$baseUrl/admin";
  static const String customerUrl = "$baseUrl/customer";

  // URL Gambar (tetap di folder public)
  static const String imageServerUrl = "http://$ipAddress/toko_mbahmeth/public/assets/products/";
}

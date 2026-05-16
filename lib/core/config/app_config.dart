class AppConfig {
  static const String ipAddress = " 192.168.1.40"; // Sesuaikan dengan IPv4 Anda

  // Base URL utama menuju folder 'api'
  static const String baseUrl = "http://$ipAddress/toko_mbahmeth/api";

  // Endpoint untuk masing-masing kategori
  static const String adminUrl = "$baseUrl/admin";
  static const String customerUrl = "$baseUrl/customer";

  // URL Gambar (tetap di folder public)
  static const String imageServerUrl = "http://$ipAddress/toko_mbahmeth/public/assets/products/";
}
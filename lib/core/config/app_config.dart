class AppConfig {
  // ─────────────────────────────────────────────────────────────────────────
  // Ganti IP ini HANYA DI SINI saat pindah Wi-Fi.
  // Cara cek IP: buka CMD → ketik ipconfig → lihat "IPv4 Address"
  // ─────────────────────────────────────────────────────────────────────────
  static const String ipAddress = "192.168.1.10";

  // URL API untuk customer & auth
  // Semua file PHP ada di: C:/laragon/www/toko_mbahmeth/api/
  static const String authBaseUrl = "http://$ipAddress/toko_mbahmeth/api";

  // URL API untuk admin CRUD
  static const String adminBaseUrl = "http://$ipAddress/toko_mbahmeth/api";

  // URL prefix gambar produk — WAJIB ada slash (/) di akhir
  // Gambar ada di: C:/laragon/www/toko_mbahmeth/public/assets/products/
  static const String imageServerUrl =
      "http://$ipAddress/toko_mbahmeth/public/assets/products/";
}
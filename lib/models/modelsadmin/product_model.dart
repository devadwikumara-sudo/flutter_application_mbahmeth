import '../../core/config/app_config.dart'; // 1. Pastikan import path-nya benar

class ProductModel {
  final String? id;
  final String? idCategory;
  final String name;
  final int price;
  final int stock;
  final String imagePath;
  final String? description;
  final String? category;

  ProductModel({
    this.id,
    this.idCategory,
    required this.name,
    required this.price,
    required this.stock,
    required this.imagePath,
    this.description,
    this.category,
  });

  // 2. AMBIL DARI APPCONFIG: Jangan tulis manual "localhost" lagi
  // Kita gunakan AppConfig.imageServerUrl yang sudah berisi IP Address
  static const String imageBaseUrl = AppConfig.imageServerUrl;

  // Getter ini sekarang akan otomatis mengikuti IP yang ada di AppConfig
  String get fullImageUrl => "$imageBaseUrl$imagePath";

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // Gunakan toString() untuk menjaga keamanan data jika JSON berbentuk int
      id: json['id_product']?.toString(),
      idCategory: json['id_category']?.toString(),
      name: json['nama_produk'] ?? '',
      price: int.tryParse(json['harga'].toString()) ?? 0,
      stock: int.tryParse(json['stok'].toString()) ?? 0,
      imagePath: json['gambar_produk'] ?? '',
      description: json['deskripsi'],
      category: json['nama_kategori'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product': id,
      'id_category': idCategory,
      'nama_produk': name,
      'harga': price,
      'stok': stock,
      'gambar_produk': imagePath,
      'deskripsi': description,
    };
  }
}
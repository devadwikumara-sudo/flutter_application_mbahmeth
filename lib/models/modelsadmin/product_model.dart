class ProductModel {
  final String? id;
  final String name;
  final int price;
  final int stock;
  final String imagePath;
  final String? description;
  final String? category;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imagePath,
    this.description,
    this.category,
  });

  // localhost ketika upload gambar
  static const String imageBaseUrl = "http://localhost/api_pertanian/uploads/";

  // Getter untuk memanggil URL gambar secara otomatis
  String get fullImageUrl => "$imageBaseUrl$imagePath";

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id_produk']?.toString(),
      name: json['nama_produk'] ?? '',
      price: int.tryParse(json['harga'].toString()) ?? 0,
      stock: int.tryParse(json['stok'].toString()) ?? 0,
      imagePath: json['foto'] ?? '',
      description: json['deskripsi'],
      category: json['kategori'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': id,
      'nama_produk': name,
      'harga': price,
      'stok': stock,
      'foto': imagePath,
      'deskripsi': description,
      'kategori': category,
    };
  }
}

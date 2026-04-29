class Product {
  final String? id;
  final String name;
  final int price;
  final int stock;
  final String category;
  final String description;
  final String? imageUrl;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.description,
    this.imageUrl,
  });

  // Untuk mengubah JSON dari PHP ke Object Flutter
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['nama_produk'],
      price: int.parse(json['harga']),
      stock: int.parse(json['stok']),
      category: json['kategori'],
      description: json['deskripsi'],
      imageUrl: json['foto'],
    );
  }

  // Untuk mengirim data dari Flutter ke PHP
  Map<String, dynamic> toJson() => {
    "id": id,
    "nama_produk": name,
    "harga": price.toString(),
    "stok": stock.toString(),
    "kategori": category,
    "deskripsi": description,
  };
} 

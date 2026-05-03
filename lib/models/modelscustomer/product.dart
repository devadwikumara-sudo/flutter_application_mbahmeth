class Product {
  final String id, name, description, category;
  final String? imageUrl;
  final int price, stock;

  Product({required this.id, required this.name, required this.price, 
           required this.stock, required this.category, required this.description, this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id_product'].toString(),
      name: json['nama_produk'],
      price: int.parse(json['harga'].toString()),
      stock: int.parse(json['stok'].toString()),
      category: json['id_category'].toString(),
      description: json['deskripsi'],
      imageUrl: json['gambar_produk'],
    );
  }
}
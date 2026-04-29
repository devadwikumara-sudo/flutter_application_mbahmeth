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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // Menggunakan .toString() agar aman jika id berupa int atau string dari database
      id: json['id_product']?.toString(), 
      name: json['nama_produk'] ?? '',
      // Trik aman: Ubah ke string dulu baru parse ke int
      price: int.parse(json['harga'].toString()), 
      stock: int.parse(json['stok'].toString()),
      category: json['nama_kategori'] ?? json['id_category'].toString(),
      description: json['deskripsi'] ?? '',
      imageUrl: json['gambar_produk'], // Sesuaikan dengan kolom 'gambar_produk' di MySQL
    );
  }

  Map<String, dynamic> toJson() => {
    "id_product": id,
    "nama_produk": name,
    "harga": price, // Kirim sebagai int saja agar lebih clean
    "stok": stock,
    "id_category": category, // Kirim ID kategori
    "deskripsi": description,
    "gambar_produk": imageUrl,
  };
}
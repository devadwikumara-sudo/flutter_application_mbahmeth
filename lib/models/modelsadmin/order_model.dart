class OrderModel {
  final String idOrder;
  final String namaProduk;
  final int harga;
  final int jumlah;
  final String gambarProduk;
  final String status;

  OrderModel({
    required this.idOrder,
    required this.namaProduk,
    required this.harga,
    required this.jumlah,
    required this.gambarProduk,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      idOrder: json['id_order'].toString(),
      namaProduk: json['nama_produk'] ?? 'Produk Tidak Diketahui',
      // Gunakan double.parse lalu konversi ke int untuk menghilangkan .00
      harga: double.tryParse(json['harga'].toString())?.toInt() ?? 0,
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      gambarProduk: json['gambar_produk'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}

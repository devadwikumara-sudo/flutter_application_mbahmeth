class OrderModel {
  final String idOrder;
  final String idUser;
  final String customerName; // Kita ambil dari join atau dummy sementara
  final int totalPrice;
  final String status; // 'Tertunda', 'Pengolahan', 'Selesai'
  final String dateOrdered;
  final String address;

  OrderModel({
    required this.idOrder,
    required this.idUser,
    required this.customerName,
    required this.totalPrice,
    required this.status,
    required this.dateOrdered,
    required this.address,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      idOrder: json['id_order'].toString(),
      idUser: json['id_user']?.toString() ?? "-", 
      customerName: json['nama_pembeli'] ?? "Pelanggan", // Sesuai kolom di DB
      totalPrice: int.tryParse(json['total_harga'].toString()) ?? 0, // Sesuai kolom di DB
      status: json['status'] ?? 'keranjang', 
      dateOrdered: json['tanggal_pesan'] ?? '', // Sesuai kolom di DB
      address: "-", // Tidak ada kolom alamat di tabel orders kamu
    );
  }
}
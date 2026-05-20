class OrderModel {
  final int idOrder;
  final int idUser;
  final String customerName;
  final String totalPrice;
  final String status;
  final String dateOrdered;
  final String metodePembayaran;
  final String metodeAmbil;
  final String namaPembeli;
  final List<dynamic> items;

  OrderModel({
    required this.idOrder,
    required this.idUser,
    required this.customerName,
    required this.totalPrice,
    required this.status,
    required this.dateOrdered,
    this.metodePembayaran = 'Bayar Di Toko',
    this.metodeAmbil = 'Ambil Di Toko',
    this.namaPembeli = '',
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Normalkan total harga menjadi string tanpa desimal
    String hargaStr = '0';
    final rawHarga = json['total_harga'];
    if (rawHarga != null) {
      final parsed = double.tryParse(rawHarga.toString()) ?? 0.0;
      hargaStr = parsed
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
    }

    // Normalkan tanggal
    String tanggal = json['tanggal_pesan']?.toString() ?? '-';
    try {
      if (tanggal != '-' && tanggal.isNotEmpty) {
        final dt = DateTime.parse(tanggal);
        const bulan = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        final jam = dt.hour.toString().padLeft(2, '0');
        final menit = dt.minute.toString().padLeft(2, '0');
        tanggal = '${dt.day} ${bulan[dt.month]} ${dt.year} $jam:$menit';
      }
    } catch (_) {}

    // Nama pelanggan: pakai nama_pembeli (snapshot) atau fallback ke customer_name
    final namaCustomer = json['nama_pembeli']?.toString().isNotEmpty == true
        ? json['nama_pembeli'].toString()
        : json['customer_name']?.toString() ??
          json['nama_lengkap']?.toString() ??
          'Pelanggan';

    return OrderModel(
      idOrder: json['id_order'].toString(),
      idUser: json['id_user'].toString(),
      customerName: json['nama_user'] ?? "Pelanggan", // Sesuaikan hasil JOIN di PHP nanti
      totalPrice: int.tryParse(json['total_price'].toString()) ?? 0,
      status: json['status'] ?? 'Tertunda',
      dateOrdered: json['date_ordered'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
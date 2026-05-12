import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String status;
  final String date;
  final String itemName;
  final String price;
  final Color statusColor;
  final List<dynamic>? items; // detail item untuk dialog
  final String? metodePembayaran;
  final String? metodeAmbil;
  final VoidCallback? onPesanLagi; // callback ke halaman katalog

  const OrderCard({
    super.key,
    required this.orderId,
    required this.status,
    required this.date,
    required this.itemName,
    required this.price,
    required this.statusColor,
    this.items,
    this.metodePembayaran,
    this.metodeAmbil,
    this.onPesanLagi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFC9F6C5),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#$orderId',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(date,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 12)),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const ClipOval(
                  child: Icon(Icons.shopping_bag,
                      color: Color(0xFF2E9900), size: 30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(itemName,
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rp $price',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  // Tombol Detail — tampilkan modal ringkasan order
                  GestureDetector(
                    onTap: () => _showDetailDialog(context),
                    child: _buildButtonWidget(
                        'Detail',
                        Colors.white.withOpacity(0.5),
                        Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Pesan Lagi — kembali ke beranda/katalog
                  GestureDetector(
                    onTap: onPesanLagi ??
                        () => Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                    child: _buildButtonWidget(
                        'Pesan Lagi',
                        const Color(0xFF577E3D),
                        Colors.white,
                        icon: Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonWidget(String label, Color bgColor, Color textColor,
      {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 4)
          ],
          Text(label,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: Color(0xFF2E9900), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Detail Pesanan #$orderId',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info order
            _detailRow('Tanggal', date),
            _detailRow('Status', status,
                valueColor: statusColor),
            if (metodePembayaran != null)
              _detailRow('Pembayaran', metodePembayaran!),
            if (metodeAmbil != null)
              _detailRow('Pengambilan', metodeAmbil!),

            const Divider(height: 28),

            // Daftar item
            if (items != null && items!.isNotEmpty) ...[
              const Text('Produk Dipesan',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              ...items!.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9F6C5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: Color(0xFF2E9900), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama_produk']?.toString() ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${item['jumlah']} x Rp ${_fmt(item['harga'])}',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${_fmt(item['subtotal'])}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 20),
            ],

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Rp $price',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2E9900))),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol tutup
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9900),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Tutup',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black54, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? const Color(0xFF1D2B1D))),
        ],
      ),
    );
  }

  String _fmt(dynamic val) {
    if (val == null) return '0';
    final double n = double.tryParse(val.toString()) ?? 0;
    return n
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
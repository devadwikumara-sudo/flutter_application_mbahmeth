import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String status;
  final String date;
  final String itemName;
  final String price;
  final Color statusColor;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.status,
    required this.date,
    required this.itemName,
    required this.price,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFC9F6C5), // Warna Hijau Muda Figma
        borderRadius: BorderRadius.circular(40), // Bentuk melengkung kapsul
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      // Badge Status Putih Transparan
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(date, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
              // Avatar Produk Bulat
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const ClipOval(
                  child: Icon(Icons.shopping_bag, color: Color(0xFF2E9900), size: 30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('1 item: $itemName', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rp $price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  _buildButton('Detail', Colors.white.withOpacity(0.5), Colors.black54),
                  const SizedBox(width: 8),
                  status == 'Menunggu'
                      ? _buildButton('Batalkan', const Color(0xFFFEE2E2), Colors.red)
                      : _buildButton('Pesan Lagi', const Color(0xFF577E3D), Colors.white, icon: Icons.refresh),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color bgColor, Color textColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: textColor, size: 14), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
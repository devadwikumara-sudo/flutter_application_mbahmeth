import 'package:flutter/material.dart';
import 'history_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Return ListView secara langsung karena AppBar sudah diatur di HomeScreen
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        NotificationCard(
          orderId: '8492',
          status: 'Selesai',
          time: '24 Okt 2026 • 10:30 WIB',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
        NotificationCard(
          orderId: '8495',
          status: 'Selesai',
          time: 'Hari ini • 14:15 WIB',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
        NotificationCard(
          orderId: '8498',
          status: 'Selesai',
          time: 'Hari ini • 15:45 WIB',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
      ],
    );
  }
}

// DEFINISI WIDGET CARD (Wajib ada agar tidak error "merah")
class NotificationCard extends StatelessWidget {
  final String orderId;
  final String status;
  final String time;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.orderId,
    required this.status,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFC9F6C5), // Hijau muda sesuai tema
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#$orderId',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Color(0xFF2E9900),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const ClipOval(
                child: Icon(Icons.inventory_2, color: Color(0xFF2E9900), size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
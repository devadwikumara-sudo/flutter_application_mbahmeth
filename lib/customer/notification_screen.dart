import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'history_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_user') ?? 0;

      if (userId == 0) {
        setState(() => _isLoading = false);
        return;
      }

      // Ambil history (status checkout = pesanan selesai)
      final data = await _api.getHistory(userId);
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  String _formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final dt = DateTime.parse(tanggal);
      const bulan = [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final jam = dt.hour.toString().padLeft(2, '0');
      final menit = dt.minute.toString().padLeft(2, '0');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tglOrder = DateTime(dt.year, dt.month, dt.day);

      if (tglOrder == today) {
        return 'Hari ini • $jam:$menit WIB';
      }
      return '${dt.day} ${bulan[dt.month]} ${dt.year} • $jam:$menit WIB';
    } catch (_) {
      return tanggal ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E9900)),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Tidak dapat memuat notifikasi',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9900)),
              onPressed: _loadNotifications,
              child: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_outlined,
                size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada notifikasi',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Tampilkan 1 notifikasi per order (tidak duplikat)
    return RefreshIndicator(
      color: const Color(0xFF2E9900),
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final order = _notifications[index];
          final orderId = order['id_order']?.toString() ?? '-';
          final status = order['status']?.toString();
          final tanggal = _formatTanggal(order['tanggal_pesan']);

          return NotificationCard(
            orderId: orderId,
            status: status == 'checkout' ? 'Selesai' : (status ?? '-'),
            time: tanggal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          );
        },
      ),
    );
  }
}

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
          color: const Color(0xFFC9F6C5),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
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
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12),
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
                child: Icon(Icons.inventory_2,
                    color: Color(0xFF2E9900), size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
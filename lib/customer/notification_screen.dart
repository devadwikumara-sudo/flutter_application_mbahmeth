import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';

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
  void didUpdateWidget(covariant NotificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Panggil load lagi jika diperlukan atau pastikan SharedPreferences terbaru
    _loadNotifications();
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
  
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      // Gunakan reload() untuk memastikan mendapatkan data terbaru dari disk
      await prefs.reload(); 
      final userId = prefs.getInt('id_user') ?? 0;

    if (userId == 0) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
      return;
    }

    final data = await _api.getHistory(userId);
      if (mounted) {
        data.sort((a, b) {
          final tA = DateTime.tryParse(a['tanggal_pesan'] ?? '') ?? DateTime(2000);
          final tB = DateTime.tryParse(b['tanggal_pesan'] ?? '') ?? DateTime(2000);
          return tB.compareTo(tA);
        });
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
      const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      final jam = dt.hour.toString().padLeft(2, '0');
      final menit = dt.minute.toString().padLeft(2, '0');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tglOrder = DateTime(dt.year, dt.month, dt.day);
      final yesterday = today.subtract(const Duration(days: 1));

      if (tglOrder == today) return 'Hari ini • $jam:$menit';
      if (tglOrder == yesterday) return 'Kemarin • $jam:$menit';
      return '${dt.day} ${bulan[dt.month]} ${dt.year} • $jam:$menit';
    } catch (_) {
      return tanggal;
    }
  }

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final double nilai = double.tryParse(harga.toString()) ?? 0;
    return 'Rp${nilai.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  void _showDetailPesanan(
      BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailNotifSheet(
        order: order,
        formatHarga: _formatHarga,
        formatTanggal: _formatTanggal,
        baseUrl: AppConfig.imageServerUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dipakai sebagai tab content — tanpa Scaffold sendiri
    // SafeArea untuk mencegah konten nabrak status bar
    return SafeArea(
      bottom: false,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.primaryGreen, strokeWidth: 2),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 32, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 14),
            const Text('Gagal memuat notifikasi',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            Text('Periksa koneksi internetmu',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  size: 36, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 14),
            const Text('Belum Ada Notifikasi',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text('Notifikasi pesanan akan muncul di sini',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadNotifications,
      child: CustomScrollView(
        slivers: [
          // SafeArea padding agar konten tidak nabrak status bar
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notifications_active_rounded,
                            color: AppColors.primaryGreen, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Status Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_notifications.length} Pesanan',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List notifikasi
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final order = _notifications[i];
                return _buildNotifCard(ctx, order);
              },
              childCount: _notifications.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildNotifCard(BuildContext context, dynamic order) {
    final items = order['items'] as List? ?? [];
    final firstItem = items.isNotEmpty ? items[0] : null;
    final gambar = firstItem?['gambar_produk']?.toString() ?? '';
    final imgUrl = '${AppConfig.imageServerUrl}$gambar';
    final orderId = order['id_order']?.toString() ?? '-';
    final namaItem = firstItem?['nama_produk']?.toString() ?? 'Produk';
    final extraCount = items.length - 1;
    final isNew = _isToday(order['tanggal_pesan']);

    return GestureDetector(
      onTap: () =>
          _showDetailPesanan(context, Map<String, dynamic>.from(order)),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNew
                ? AppColors.primaryGreen.withOpacity(0.3)
                : AppColors.cardBorder,
            width: isNew ? 1.5 : 1,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Gambar produk
            Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      imgUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: AppColors.successLight,
                        child: const Icon(Icons.eco_rounded,
                            color: AppColors.primaryGreen, size: 28),
                      ),
                    ),
                  ),
                  // Dot baru
                  if (isNew)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Badge "Selesai"
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 11,
                                  color: AppColors.primaryGreen),
                              SizedBox(width: 3),
                              Text(
                                'Selesai',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTanggal(order['tanggal_pesan']),
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pesanan #$orderId Selesai',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      extraCount > 0
                          ? '$namaItem +$extraCount lainnya'
                          : namaItem,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatHarga(order['total_harga']),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade300, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(String? tanggal) {
    if (tanggal == null) return false;
    try {
      final dt = DateTime.parse(tanggal);
      final now = DateTime.now();
      return dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day;
    } catch (_) {
      return false;
    }
  }
}

// ── Bottom Sheet Detail Notifikasi ─────────────────────────────────────────
class _DetailNotifSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final String Function(dynamic) formatHarga;
  final String Function(String?) formatTanggal;
  final String baseUrl;

  const _DetailNotifSheet({
    required this.order,
    required this.formatHarga,
    required this.formatTanggal,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List? ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 4),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('Detail Notifikasi',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 17)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Selesai',
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),

            Divider(
                height: 20,
                thickness: 1,
                color: Colors.grey.shade100,
                indent: 20,
                endIndent: 20),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Sukses banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pesanan Selesai!',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.textDark)),
                            Text(
                              'Pesanan #${order['id_order']} berhasil',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                            label: 'No. Pesanan',
                            value: '#${order['id_order']}'),
                        _InfoRow(
                            label: 'Tanggal',
                            value: formatTanggal(order['tanggal_pesan'])),
                        _InfoRow(
                            label: 'Metode Bayar',
                            value: order['metode_pembayaran']
                                    ?.toString() ??
                                'Bayar Di Toko'),
                        _InfoRow(
                            label: 'Metode Ambil',
                            value: order['metode_ambil']?.toString() ??
                                'Ambil Di Toko'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Produk Dipesan',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 10),

                  ...items.map<Widget>((item) {
                    final gambar =
                        item['gambar_produk']?.toString() ?? '';
                    final imgUrl = '$baseUrl$gambar';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imgUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 52,
                                height: 52,
                                color: AppColors.successLight,
                                child: const Icon(Icons.eco_rounded,
                                    color: AppColors.primaryGreen,
                                    size: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_produk']?.toString() ?? '-',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${formatHarga(item['harga'])} × ${item['jumlah']}',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatHarga(item['subtotal']),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }),

                  Divider(height: 24, color: Colors.grey.shade100),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text(
                          formatHarga(order['total_harga']),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tutup',
                          style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}
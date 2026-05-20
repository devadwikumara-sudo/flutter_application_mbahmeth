import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/customer/receipt_widget.dart';
import 'package:flutter_application_mbahmeth/customer/receipt_service.dart';

/// Prefix kunci SharedPreferences untuk menyimpan daftar id_order
/// yang stuknya sudah diambil (disimpan ke galeri).
/// Key dibuat per-user: 'receipt_taken_ids_<id_user>'
/// agar data tidak tercampur antar akun dan tetap ada walau logout/login ulang.
const String _kReceiptTakenKeyPrefix = 'receipt_taken_ids_';

/// Helper untuk mendapatkan key yang terikat ke user tertentu.
String _receiptKeyForUser(int userId) => '$_kReceiptTakenKeyPrefix$userId';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _notifications = [];
  Set<int> _receiptTakenIds = {}; // id_order yang stuknya sudah diambil
  bool _isLoading = true;
  bool _hasError = false;
  int _currentUserId = 0; // simpan userId agar dipakai saat _markReceiptTaken

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void didUpdateWidget(covariant NotificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadAll();
  }

  // ── Load data notifikasi + status struk yang sudah diambil ────────────────
  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _hasError = false; });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final userId = prefs.getInt('id_user') ?? 0;

      // Ambil daftar id_order yang stuknya sudah diambil — pakai key per-user
      // sehingga data tetap ada walau logout/login ulang dengan akun yang sama,
      // dan tidak tercampur dengan akun lain di perangkat yang sama.
      _currentUserId = userId;
      final takenList = prefs.getStringList(_receiptKeyForUser(userId)) ?? [];
      _receiptTakenIds = takenList.map((e) => int.tryParse(e) ?? -1).toSet();

      if (userId == 0) {
        setState(() { _notifications = []; _isLoading = false; });
        return;
      }

      final data = await _api.getHistory(userId);
      data.sort((a, b) {
        final tA = DateTime.tryParse(a['tanggal_pesan'] ?? '') ?? DateTime(2000);
        final tB = DateTime.tryParse(b['tanggal_pesan'] ?? '') ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      if (mounted) {
        setState(() { _notifications = data; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
    }
  }

  // ── Tandai struk sudah diambil (simpan ke SharedPreferences per-user) ───────
  Future<void> _markReceiptTaken(int idOrder) async {
    final prefs = await SharedPreferences.getInstance();
    _receiptTakenIds.add(idOrder);
    // Gunakan key yang terikat ke userId agar persisten meski logout/login ulang
    await prefs.setStringList(
      _receiptKeyForUser(_currentUserId),
      _receiptTakenIds.map((e) => e.toString()).toList(),
    );
    if (mounted) setState(() {});
  }

  bool _isReceiptTaken(int idOrder) => _receiptTakenIds.contains(idOrder);

  // ── Pesanan Selesai yang stuknya BELUM diambil ────────────────────────────
  List<dynamic> get _pendingReceiptOrders => _notifications.where((o) {
        final s = o['status']?.toString().toLowerCase();
        final id = int.tryParse(o['id_order']?.toString() ?? '0') ?? 0;
        return (s == 'selesai' || s == 'checkout') && !_isReceiptTaken(id);
      }).toList();

  // ── Helpers format ────────────────────────────────────────────────────────
  String _formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final dt = DateTime.parse(tanggal);
      const bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
      final jam = dt.hour.toString().padLeft(2, '0');
      final menit = dt.minute.toString().padLeft(2, '0');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tglOrder = DateTime(dt.year, dt.month, dt.day);
      if (tglOrder == today) return 'Hari ini • $jam:$menit';
      if (tglOrder == today.subtract(const Duration(days: 1))) return 'Kemarin • $jam:$menit';
      return '${dt.day} ${bulan[dt.month]} ${dt.year} • $jam:$menit';
    } catch (_) { return tanggal; }
  }

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final double nilai = double.tryParse(harga.toString()) ?? 0;
    return 'Rp${nilai.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
    )}';
  }

  // ── Status helpers ─────────────────────────────────────────────────────────
  // PENTING: nilai DB tetap 'Pengolahan', label tampilan → 'Diproses'
  String _labelStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'tertunda':   return 'Tertunda';
      case 'pengolahan': return 'Diproses';   // ← label tampilan diubah
      case 'selesai':
      case 'checkout':   return 'Selesai';
      case 'dibatalkan': return 'Dibatalkan';
      default:           return status?.toString() ?? '-';
    }
  }

  Color _colorStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'tertunda':   return const Color(0xFFF59E0B);
      case 'pengolahan': return const Color(0xFF3B82F6);
      case 'selesai':
      case 'checkout':   return AppColors.primaryGreen;
      case 'dibatalkan': return const Color(0xFFEF4444);
      default:           return Colors.grey;
    }
  }

  Color _bgStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'tertunda':   return const Color(0xFFFEF3C7);
      case 'pengolahan': return const Color(0xFFDBEAFE);
      case 'selesai':
      case 'checkout':   return AppColors.successLight;
      case 'dibatalkan': return const Color(0xFFFEE2E2);
      default:           return Colors.grey.shade100;
    }
  }

  IconData _iconStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'tertunda':   return Icons.hourglass_top_rounded;
      case 'pengolahan': return Icons.timelapse_rounded;
      case 'selesai':
      case 'checkout':   return Icons.check_circle_rounded;
      case 'dibatalkan': return Icons.cancel_rounded;
      default:           return Icons.info_outline_rounded;
    }
  }

  bool _isSelesai(dynamic status) {
    final s = status?.toString().toLowerCase();
    return s == 'selesai' || s == 'checkout';
  }

  // ── Simpan struk ke galeri ────────────────────────────────────────────────
  Future<void> _saveReceiptFromOrder(
      BuildContext context, Map<String, dynamic> order) async {
    final items = (order['items'] as List? ?? [])
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
    final totalHarga =
        double.tryParse(order['total_harga']?.toString() ?? '0') ?? 0;
    final idOrder =
        int.tryParse(order['id_order']?.toString() ?? '0') ?? 0;
    final metodePembayaran =
        order['metode_pembayaran']?.toString() ?? 'Bayar Di Toko';
    final metodeAmbil = order['metode_ambil']?.toString() ?? 'Ambil Di Toko';
    final namaPembeli = order['nama_pembeli']?.toString() ?? '';
    final tanggal =
        DateTime.tryParse(order['tanggal_pesan']?.toString() ?? '') ??
            DateTime.now();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 12),
          Text('Menyimpan struk ke galeri...'),
        ]),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }

    final saved = await ReceiptService.saveReceiptToGallery(
      child: ReceiptWidget(
        idOrder: idOrder,
        cartItems: items,
        totalHarga: totalHarga,
        metodePembayaran: metodePembayaran,
        metodeAmbil: metodeAmbil,
        tanggal: tanggal,
        namaPembeli: namaPembeli,
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (saved) {
      // Tandai struk sudah diambil → hilang dari banner peringatan
      await _markReceiptTaken(idOrder);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Struk berhasil disimpan ke galeri!'),
        ]),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.error_outline, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Gagal menyimpan struk, coba lagi.'),
        ]),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _showDetailPesanan(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailNotifSheet(
        order: order,
        formatHarga: _formatHarga,
        formatTanggal: _formatTanggal,
        labelStatus: _labelStatus,
        colorStatus: _colorStatus,
        bgStatus: _bgStatus,
        isSelesai: _isSelesai,
        isReceiptTaken: _isReceiptTaken,
        baseUrl: AppConfig.imageServerUrl,
        onSaveReceipt: () => _saveReceiptFromOrder(context, order),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2),
      );
    }
    if (_hasError) return _buildErrorState();
    if (_notifications.isEmpty) return _buildEmptyState();

    final pendingReceipts = _pendingReceiptOrders;

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadAll,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── BANNER STRUK BELUM DIAMBIL ──────────────────────────────────
          if (pendingReceipts.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildPendingReceiptBanner(pendingReceipts),
            ),

          // ── Section header ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
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
                    const Text('Status Pesanan',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textDark)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${_notifications.length} Pesanan',
                        style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          // ── List notifikasi ──────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildNotifCard(ctx, _notifications[i]),
              childCount: _notifications.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Banner peringatan struk belum diambil ──────────────────────────────────
  Widget _buildPendingReceiptBanner(List<dynamic> pending) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF166534), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Struk Belum Diambil',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                      Text(
                        '${pending.length} pesanan selesai menunggu struk',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Badge jumlah
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${pending.length}',
                        style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),

          // Daftar pesanan yang stuknya belum diambil
          ...pending.map((order) {
            final items = order['items'] as List? ?? [];
            final firstItem = items.isNotEmpty ? items[0] : null;
            final namaItem =
                firstItem?['nama_produk']?.toString() ?? 'Produk';
            final extra = items.length - 1;
            final idOrder =
                int.tryParse(order['id_order']?.toString() ?? '0') ?? 0;

            return Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pesanan #$idOrder',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                        Text(
                          extra > 0 ? '$namaItem +$extra lainnya' : namaItem,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Tombol ambil struk langsung dari banner
                  GestureDetector(
                    onTap: () => _saveReceiptFromOrder(
                        context, Map<String, dynamic>.from(order)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded,
                              size: 14, color: AppColors.primaryGreen),
                          SizedBox(width: 4),
                          Text('Ambil Struk',
                              style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Kartu notifikasi per pesanan ───────────────────────────────────────────
  Widget _buildNotifCard(BuildContext context, dynamic order) {
    final status = order['status']?.toString() ?? '';
    final statusLabel = _labelStatus(status);
    final statusColor = _colorStatus(status);
    final statusBg = _bgStatus(status);
    final statusIcon = _iconStatus(status);
    final selesai = _isSelesai(status);
    final idOrder = int.tryParse(order['id_order']?.toString() ?? '0') ?? 0;
    final receiptTaken = _isReceiptTaken(idOrder);

    final items = order['items'] as List? ?? [];
    final firstItem = items.isNotEmpty ? items[0] : null;
    final gambar = firstItem?['gambar_produk']?.toString() ?? '';
    final imgUrl = '${AppConfig.imageServerUrl}$gambar';
    final namaItem = firstItem?['nama_produk']?.toString() ?? 'Produk';
    final extraCount = items.length - 1;

    return GestureDetector(
      onTap: () =>
          _showDetailPesanan(context, Map<String, dynamic>.from(order)),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (selesai && !receiptTaken)
                ? AppColors.primaryGreen.withOpacity(0.4)
                : AppColors.cardBorder,
            width: (selesai && !receiptTaken) ? 1.5 : 1,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            // ── Baris utama ────────────────────────────────────────────
            Row(
              children: [
                // Gambar produk
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imgUrl, width: 64, height: 64, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64, height: 64, color: statusBg,
                            child: Icon(Icons.eco_rounded,
                                color: statusColor, size: 28),
                          ),
                        ),
                      ),
                      // Dot merah jika struk belum diambil
                      if (selesai && !receiptTaken)
                        Positioned(
                          top: 0, right: 0,
                          child: Container(
                            width: 11, height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Info teks
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Badge status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, size: 11, color: statusColor),
                                  const SizedBox(width: 3),
                                  Text(statusLabel,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(_formatTanggal(order['tanggal_pesan']),
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade400)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pesanan #$idOrder $statusLabel',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textDark),
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
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade300, size: 22),
                ),
              ],
            ),

            // ── Tombol Ambil Struk — HANYA jika Selesai & belum diambil ──
            if (selesai && !receiptTaken) ...[
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveReceiptFromOrder(
                        context, Map<String, dynamic>.from(order)),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Ambil Struk',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],

            // ── Label struk sudah diambil ──────────────────────────────
            if (selesai && receiptTaken) ...[
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text('Struk sudah tersimpan',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    // Tetap bisa download ulang
                    GestureDetector(
                      onTap: () => _saveReceiptFromOrder(
                          context, Map<String, dynamic>.from(order)),
                      child: Text('Unduh lagi',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── State kosong & error ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(
              color: AppColors.successLight, shape: BoxShape.circle),
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
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
      ]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
              color: Colors.grey.shade100, shape: BoxShape.circle),
          child: Icon(Icons.wifi_off_rounded,
              size: 36, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 14),
        const Text('Gagal memuat notifikasi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 6),
        Text('Periksa koneksi internetmu',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: _loadAll,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Coba Lagi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Bottom Sheet Detail Notifikasi
// ══════════════════════════════════════════════════════════════════════════════
class _DetailNotifSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final String Function(dynamic) formatHarga;
  final String Function(String?) formatTanggal;
  final String Function(dynamic) labelStatus;
  final Color Function(dynamic) colorStatus;
  final Color Function(dynamic) bgStatus;
  final bool Function(dynamic) isSelesai;
  final bool Function(int) isReceiptTaken;
  final String baseUrl;
  final VoidCallback onSaveReceipt;

  const _DetailNotifSheet({
    required this.order,
    required this.formatHarga,
    required this.formatTanggal,
    required this.labelStatus,
    required this.colorStatus,
    required this.bgStatus,
    required this.isSelesai,
    required this.isReceiptTaken,
    required this.baseUrl,
    required this.onSaveReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List? ?? [];
    final status = order['status'];
    final statusLabel = labelStatus(status);
    final statusColor = colorStatus(status);
    final statusBg = bgStatus(status);
    final selesai = isSelesai(status);
    final dibatalkan = status?.toString().toLowerCase() == 'dibatalkan';
    final idOrder = int.tryParse(order['id_order']?.toString() ?? '0') ?? 0;
    final receiptTaken = isReceiptTaken(idOrder);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 4),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              const Text('Detail Notifikasi',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: statusBg, borderRadius: BorderRadius.circular(10)),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ]),
          ),

          Divider(height: 20, thickness: 1,
              color: Colors.grey.shade100, indent: 20, endIndent: 20),

          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                // ── Banner status ──────────────────────────────────────────
                _buildBanner(
                  color: statusBg,
                  iconColor: statusColor,
                  icon: selesai
                      ? Icons.check_rounded
                      : dibatalkan
                          ? Icons.close_rounded
                          : Icons.timelapse_rounded,
                  title: selesai
                      ? 'Pesanan Selesai!'
                      : dibatalkan
                          ? 'Pesanan Dibatalkan'
                          : 'Sedang Diproses',
                  subtitle: 'Pesanan #${order['id_order']} $statusLabel',
                ),

                const SizedBox(height: 16),

                // ── Info pesanan ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    _InfoRow(label: 'No. Pesanan', value: '#${order['id_order']}'),
                    _InfoRow(label: 'Tanggal', value: formatTanggal(order['tanggal_pesan'])),
                    _InfoRow(
                        label: 'Metode Bayar',
                        value: order['metode_pembayaran']?.toString() ?? 'Bayar Di Toko'),
                    _InfoRow(
                        label: 'Metode Ambil',
                        value: order['metode_ambil']?.toString() ?? 'Ambil Di Toko'),
                  ]),
                ),

                const SizedBox(height: 16),

                const Text('Produk Dipesan',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 10),

                // ── Daftar produk ──────────────────────────────────────────
                ...items.map<Widget>((item) {
                  final imgUrl = '$baseUrl${item['gambar_produk'] ?? ''}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder)),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imgUrl, width: 52, height: 52, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 52, height: 52, color: statusBg,
                            child: Icon(Icons.eco_rounded,
                                color: statusColor, size: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nama_produk']?.toString() ?? '-',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text('${formatHarga(item['harga'])} × ${item['jumlah']}',
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(formatHarga(item['subtotal']),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  );
                }),

                Divider(height: 24, color: Colors.grey.shade100),

                // ── Total ──────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: statusBg, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(formatHarga(order['total_harga']),
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: statusColor)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Bagian struk (HANYA jika Selesai) ─────────────────────
                if (selesai) ...[
                  // Kotak info struk
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receiptTaken
                                  ? 'Struk Sudah Tersimpan'
                                  : 'Struk Pesanan Tersedia',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              receiptTaken
                                  ? 'Kamu masih bisa unduh ulang struk ini'
                                  : 'Simpan struk sebagai bukti pembelian',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onSaveReceipt();
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(
                        receiptTaken
                            ? 'Unduh Ulang Struk'
                            : 'Simpan Struk ke Galeri',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Tombol tutup ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primaryGreen, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
        ]),
      ),
    );
  }

  Widget _buildBanner({
    required Color color,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.textDark)),
          Text(subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ]),
      ]),
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
      child: Row(children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ),
      ]),
    );
  }
}
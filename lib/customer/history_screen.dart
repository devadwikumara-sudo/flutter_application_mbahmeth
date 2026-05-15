import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<dynamic> _allOrders = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _userId = 0;
  late TabController _tabController;

  final List<_TabData> _tabs = [
    _TabData(label: 'Semua', icon: Icons.list_rounded),
    _TabData(label: 'Diproses', icon: Icons.timelapse_rounded),
    _TabData(label: 'Selesai', icon: Icons.check_circle_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('id_user') ?? 0;
      if (_userId == 0) {
        setState(() => _isLoading = false);
        return;
      }

      List<dynamic> data = [];
      try {
        data = await _api.getOrdersByUser(_userId);
      } catch (_) {
        data = await _api.getHistory(_userId);
      }

      data.sort((a, b) {
        final tA =
            DateTime.tryParse(a['tanggal_pesan'] ?? '') ?? DateTime(2000);
        final tB =
            DateTime.tryParse(b['tanggal_pesan'] ?? '') ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      if (mounted) {
        setState(() {
          _allOrders = data;
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

  List<dynamic> _filteredOrders(String tab) {
    if (tab == 'Semua') return _allOrders;
    if (tab == 'Diproses') {
      return _allOrders
          .where((o) => o['status']?.toString() == 'keranjang')
          .toList();
    }
    if (tab == 'Selesai') {
      return _allOrders
          .where((o) => o['status']?.toString() == 'checkout')
          .toList();
    }
    return _allOrders;
  }

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final double nilai = double.tryParse(harga.toString()) ?? 0;
    return 'Rp${nilai.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final dt = DateTime.parse(tanggal);
      const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      final jam = dt.hour.toString().padLeft(2, '0');
      final menit = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${bulan[dt.month]} ${dt.year}, $jam:$menit';
    } catch (_) {
      return tanggal;
    }
  }

  String _labelStatus(dynamic status) {
    switch (status?.toString()) {
      case 'checkout': return 'Selesai';
      case 'keranjang': return 'Diproses';
      default: return status?.toString() ?? '-';
    }
  }

  Color _warnaStatus(dynamic status) {
    switch (status?.toString()) {
      case 'checkout': return AppColors.primaryGreen;
      case 'keranjang': return AppColors.warning;
      default: return Colors.grey;
    }
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _OrderSearchDelegate(
        orders: _allOrders,
        formatHarga: _formatHarga,
        formatTanggal: _formatTanggal,
        labelStatus: _labelStatus,
        warnaStatus: _warnaStatus,
        onTapOrder: (order) => _showDetailPesanan(context, order),
      ),
    );
  }

  void _showDetailPesanan(
      BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailPesananSheet(
        order: order,
        formatHarga: _formatHarga,
        formatTanggal: _formatTanggal,
        labelStatus: _labelStatus,
        warnaStatus: _warnaStatus,
        baseUrl: AppConfig.imageServerUrl,
        onPesanLagi: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  onPressed: () => _showSearch(context),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 60),
              title: const Text(
                'Riwayat Pesanan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.primaryGreen,
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs
                      .map((t) => Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(t.icon, size: 14),
                                const SizedBox(width: 5),
                                Text(t.label),
                              ],
                            ),
                          ))
                      .toList(),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
        ],
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.primaryGreen, strokeWidth: 2),
      );
    }

    if (_userId == 0) {
      return _buildEmptyState(
        icon: Icons.person_off_rounded,
        title: 'Belum Login',
        subtitle: 'Silakan login untuk melihat riwayat pesanan',
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return TabBarView(
      controller: _tabController,
      children: _tabs.map((t) {
        final orders = _filteredOrders(t.label);
        return orders.isEmpty
            ? _buildEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Belum Ada Pesanan',
                subtitle: 'Pesanan ${t.label.toLowerCase()} akan muncul di sini',
              )
            : RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: _loadHistory,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) =>
                      _buildOrderCard(ctx, orders[i]),
                ),
              );
      }).toList(),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    final status = order['status']?.toString() ?? '';
    final statusLabel = _labelStatus(status);
    final statusColor = _warnaStatus(status);
    final items = order['items'] as List? ?? [];
    final firstItem = items.isNotEmpty ? items[0] : null;
    final namaItem = firstItem?['nama_produk']?.toString() ?? 'Produk';
    final extraCount = items.length - 1;

    // Warna bg badge
    final Color statusBg = statusColor == AppColors.primaryGreen
        ? AppColors.successLight
        : statusColor == AppColors.warning
            ? const Color(0xFFFEF3C7)
            : Colors.grey.shade100;

    return GestureDetector(
      onTap: () =>
          _showDetailPesanan(context, Map<String, dynamic>.from(order)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.successLight.withOpacity(0.4),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shopping_bag_rounded,
                        color: AppColors.primaryGreen, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesanan #${order['id_order']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          _formatTanggal(order['tanggal_pesan']),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nama produk
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record,
                      size: 8, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      extraCount > 0
                          ? '$namaItem +$extraCount produk lainnya'
                          : namaItem,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMedium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade100),

            // Footer
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400)),
                      Text(
                        _formatHarga(order['total_harga']),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: AppColors.primaryGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded,
                size: 36, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          const Text('Tidak dapat memuat data',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Periksa koneksi internetmu',
              style:
                  TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class tab ─────────────────────────────────────────────────────────
class _TabData {
  final String label;
  final IconData icon;
  const _TabData({required this.label, required this.icon});
}

// ── Search Delegate ────────────────────────────────────────────────────────
class _OrderSearchDelegate extends SearchDelegate<String> {
  final List<dynamic> orders;
  final String Function(dynamic) formatHarga;
  final String Function(String?) formatTanggal;
  final String Function(dynamic) labelStatus;
  final Color Function(dynamic) warnaStatus;
  final void Function(Map<String, dynamic>) onTapOrder;

  _OrderSearchDelegate({
    required this.orders,
    required this.formatHarga,
    required this.formatTanggal,
    required this.labelStatus,
    required this.warnaStatus,
    required this.onTapOrder,
  });

  @override
  String get searchFieldLabel => 'Cari pesanan atau produk...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  List<dynamic> _getResults() {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return orders.where((order) {
      final id = order['id_order']?.toString() ?? '';
      final items = order['items'] as List? ?? [];
      final namaItems =
          items.map((i) => i['nama_produk']?.toString() ?? '').join(' ');
      return id.contains(q) || namaItems.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildOrderTile(BuildContext context, dynamic order) {
    final items = order['items'] as List? ?? [];
    final firstItem = items.isNotEmpty ? items[0] : null;
    final namaItem = firstItem?['nama_produk']?.toString() ?? 'Produk';
    final extraCount = items.length - 1;
    final status = order['status']?.toString() ?? '';
    final statusLabel = labelStatus(status);
    final statusColor = warnaStatus(status);

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.shopping_bag_rounded,
            color: AppColors.primaryGreen, size: 22),
      ),
      title: Text(
        'Pesanan #${order['id_order']}',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: Text(
        extraCount > 0 ? '$namaItem +$extraCount lainnya' : namaItem,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusLabel,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor)),
          ),
          const SizedBox(height: 4),
          Text(
            formatHarga(order['total_harga']),
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.primaryGreen),
          ),
        ],
      ),
      onTap: () {
        close(context, '');
        onTapOrder(Map<String, dynamic>.from(order));
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = _getResults();
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Tidak ada hasil untuk "$query"',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (ctx, i) => _buildOrderTile(ctx, results[i]),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _getResults();
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Cari berdasarkan nomor pesanan atau nama produk',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (ctx, i) => _buildOrderTile(ctx, results[i]),
    );
  }
}

// ── Bottom Sheet Detail Pesanan ────────────────────────────────────────────
class _DetailPesananSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final String Function(dynamic) formatHarga;
  final String Function(String?) formatTanggal;
  final String Function(dynamic) labelStatus;
  final Color Function(dynamic) warnaStatus;
  final String baseUrl;
  final VoidCallback onPesanLagi;

  const _DetailPesananSheet({
    required this.order,
    required this.formatHarga,
    required this.formatTanggal,
    required this.labelStatus,
    required this.warnaStatus,
    required this.baseUrl,
    required this.onPesanLagi,
  });

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List? ?? [];
    final statusLabel = labelStatus(order['status']);
    final statusColor = warnaStatus(order['status']);
    final Color statusBg = statusColor == AppColors.primaryGreen
        ? AppColors.successLight
        : statusColor == AppColors.warning
            ? const Color(0xFFFEF3C7)
            : Colors.grey.shade100;

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
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Detail Pesanan',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade100),

            // Konten scroll
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Sukses indikator
                  if (order['status'] == 'checkout')
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
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
                              const Text('Pesanan Selesai',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
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

                  // Info pesanan
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

                  // Produk list
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
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 56,
                                height: 56,
                                color: AppColors.successLight,
                                child: const Icon(Icons.eco_rounded,
                                    color: AppColors.primaryGreen,
                                    size: 24),
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
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatHarga(item['subtotal']),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textDark),
                          ),
                        ],
                      ),
                    );
                  }),

                  Divider(height: 24, color: Colors.grey.shade100),

                  // Total
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
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol aksi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          child: const Text('Tutup',
                              style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onPesanLagi();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          child: const Text('Pesan Lagi',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
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
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
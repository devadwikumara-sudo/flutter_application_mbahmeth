import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/modelsadmin/order_model.dart';

class OrderListPage extends StatefulWidget {
  // FIX: Parameter isEmbedded — ketika true (dipakai sebagai tab di dashboard),
  //      tombol back di header disembunyikan agar tidak menyebabkan blackscreen.
  final bool isEmbedded;

  const OrderListPage({super.key, this.isEmbedded = false});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  String _activeTab = "Tertunda";
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;

  static const _primaryGreen     = Color(0xFF2E9900);
  static const _primaryGreenDark = Color(0xFF1F6B00);
  static const _backgroundLight  = Color(0xFFF4FAF2);
  static const _backgroundWhite  = Color(0xFFFFFFFF);
  static const _textDark         = Color(0xFF1A2E1A);
  static const _textLight        = Color(0xFF8A9E8A);
  static const _textMedium       = Color(0xFF3D553D);
  static const _cardBorder       = Color(0xFFEEF5EE);
  static const _primaryRed       = Color(0xFFD32F2F);
  static const _successLight     = Color(0xFFE8F5E2);

  static const _tabs = [
    _TabConfig("Tertunda",   Color(0xFFD32F2F), Color(0xFFFFEBEB)),
    _TabConfig("Diproses",   Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    _TabConfig("Selesai",    Color(0xFF2E9900), Color(0xFFE8F5E2)),
    _TabConfig("Dibatalkan", Color(0xFF8A9E8A), Color(0xFFF4FAF2)),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().fetchAllOrders();
      setState(() {
        _allOrders = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error load orders: $e");
    }
  }

  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    final isCancel = newStatus == 'Dibatalkan';
    final Color aksiColor = isCancel ? _primaryRed : _primaryGreen;
    final String aksiLabel = isCancel ? 'Batalkan Pesanan?' : 'Konfirmasi Aksi?';
    final String aksiSub = isCancel
        ? 'Pesanan #${order.idOrder} akan dibatalkan dan stok dikembalikan.'
        : 'Status pesanan #${order.idOrder} akan diubah menjadi "$newStatus".';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _backgroundWhite,
        title: Text(aksiLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textDark)),
        content: Text(aksiSub,
            style: const TextStyle(fontSize: 13, color: _textLight)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: _textLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: aksiColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isCancel ? 'Ya, Batalkan' : 'Ya, Konfirmasi',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ApiService().updateOrderStatus(
      idOrder: order.idOrder,
      status: newStatus,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan #${order.idOrder} → $newStatus'),
          backgroundColor: isCancel ? _primaryRed : _primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await _loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengubah status. Coba lagi.'),
          backgroundColor: _primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allOrders
        .where((o) => _matchStatus(o.status, _activeTab))
        .toList();

    return Scaffold(
      backgroundColor: _backgroundLight,
      body: Column(
        children: [
          // ── Header dengan gradient ──────────────────────────────────────
          Container(
            width: double.infinity,
            // FIX: Jika embedded (tab), tidak perlu padding atas untuk status bar
            //      karena sudah ditangani oleh Scaffold parent (AdminDashboard).
            padding: EdgeInsets.fromLTRB(
              widget.isEmbedded ? 16 : 4,
              widget.isEmbedded ? 50 : 44,
              16,
              16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryGreenDark, _primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // FIX: Tombol back HANYA tampil ketika halaman di-push sebagai
                //      route terpisah (isEmbedded == false).
                //      Ketika jadi tab, tombol ini disembunyikan.
                if (!widget.isEmbedded)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                Image.asset(
                  'assets/images/x2.png',
                  height: 38,
                  errorBuilder: (c, e, s) => Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadOrders,
                  ),
                ),
              ],
            ),
          ),

          // ── Tab Bar ────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: _backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E9900).withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final count = _allOrders
                      .where((o) => _matchStatus(o.status, tab.label))
                      .length;
                  return _buildTabItem(tab, count);
                }).toList(),
              ),
            ),
          ),

          // ── List Pesanan ───────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryGreen))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: _successLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_long_outlined,
                                  size: 36, color: _textLight),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Tidak ada pesanan $_activeTab",
                              style: const TextStyle(color: _textLight),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: _primaryGreen,
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _buildOrderCard(filtered[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(_TabConfig tab, int count) {
    final isActive = _activeTab == tab.label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab.label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? tab.color : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? tab.color : _textLight,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: tab.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                      fontSize: 10,
                      color: tab.color,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final tabConfig = _tabs.firstWhere(
      (t) => t.label.toLowerCase() == _activeTab.toLowerCase(),
      orElse: () => _tabs[0],
    );

    Widget? actionButtons;
    if (_activeTab == 'Tertunda') {
      actionButtons = Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(order, 'Pengolahan'),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Terima'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _updateStatus(order, 'Dibatalkan'),
              icon: const Icon(Icons.close_rounded,
                  size: 16, color: _primaryRed),
              label: const Text('Batalkan',
                  style: TextStyle(color: _primaryRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primaryRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      );
    } else if (_activeTab == 'Diproses') {
      actionButtons = Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(order, 'Selesai'),
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: const Text('Selesai'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _updateStatus(order, 'Dibatalkan'),
              icon: const Icon(Icons.close_rounded,
                  size: 16, color: _primaryRed),
              label: const Text('Batalkan',
                  style: TextStyle(color: _primaryRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primaryRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E9900).withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: tabConfig.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                      color: tabConfig.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                order.dateOrdered,
                style: const TextStyle(color: _textLight, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Order #${order.idOrder}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: _textDark),
          ),
          const SizedBox(height: 2),
          Text(
            'Pelanggan: ${order.customerName}',
            style: const TextStyle(color: _textLight, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payment_rounded, size: 13, color: _textMedium),
                const SizedBox(width: 5),
                Text(
                  '${order.metodePembayaran}  •  ${order.metodeAmbil}',
                  style: const TextStyle(fontSize: 12, color: _textMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: _primaryGreen, size: 18),
              const SizedBox(width: 6),
              Text(
                'Rp ${order.totalPrice}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textDark),
              ),
            ],
          ),
          if (actionButtons != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEF5EE)),
            const SizedBox(height: 12),
            actionButtons,
          ],
        ],
      ),
    );
  }
}

bool _matchStatus(String dbStatus, String tabLabel) {
  final s = dbStatus.toLowerCase();
  switch (tabLabel) {
    case 'Tertunda':   return s == 'tertunda';
    case 'Diproses':   return s == 'pengolahan';
    case 'Selesai':    return s == 'selesai';
    case 'Dibatalkan': return s == 'dibatalkan';
    default:           return s == tabLabel.toLowerCase();
  }
}

class _TabConfig {
  final String label;
  final Color color;
  final Color bgColor;
  const _TabConfig(this.label, this.color, this.bgColor);
}
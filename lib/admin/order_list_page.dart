import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/modelsadmin/order_model.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  String _activeTab = "Checkout";
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;

  // Tab config: label, warna badge, warna aktif
  static const _tabs = [
    _TabConfig("Tertunda",   Color(0xFFEF4444), Color(0xFFFEE2E2)),
    _TabConfig("Diproses", Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    _TabConfig("Selesai",    Color(0xFF22C55E), Color(0xFFDCFCE7)),
    _TabConfig("Dibatalkan", Color(0xFF6B7280), Color(0xFFF3F4F6)),
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
<<<<<<< HEAD
=======
      print("Jumlah data yang diterima: ${data.length}");
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
      setState(() {
        _allOrders = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error pas load: $e");
      setState(() => _isLoading = false);
    }
  }

  // ── Update status dengan konfirmasi dialog ─────────────────────────────
  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    // Warna & teks sesuai aksi
    final isCancel = newStatus == 'Dibatalkan';
    final Color aksiColor = isCancel ? const Color(0xFFEF4444) : const Color(0xFF2E9900);
    final String aksiLabel = isCancel ? 'Batalkan Pesanan?' : 'Konfirmasi Aksi?';
    final String aksiSub = isCancel
        ? 'Pesanan #${order.idOrder} akan dibatalkan dan stok dikembalikan.'
        : 'Status pesanan #${order.idOrder} akan diubah menjadi "$newStatus".';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(aksiLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(aksiSub,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: aksiColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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

    // Panggil API update status
    final success = await ApiService().updateOrderStatus(
      idOrder: order.idOrder,
      status: newStatus,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan #${order.idOrder} → $newStatus'),
          backgroundColor:
              isCancel ? const Color(0xFFEF4444) : const Color(0xFF2E9900),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await _loadOrders(); // Refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengubah status. Coba lagi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final filtered = _allOrders
        .where((o) =>
            _matchStatus(o.status, _activeTab))
=======
    // Memfilter list berdasarkan tab yang aktif
    List<OrderModel> filteredOrders = _allOrders
        .where((o) => o.status.toLowerCase() == _activeTab.toLowerCase())
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 40, 20, 20),
            decoration: const BoxDecoration(color: Color(0xFF2E9900)),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.eco, color: Color(0xFF2E9900)),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    Text("MbahMeth",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text("Portal Admin",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
=======
                    Text(
                      "MbahMeth",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Portal Admin",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadOrders,
                ),
              ],
            ),
          ),

          // ── Tab Bar ──────────────────────────────────────────────────────
          Container(
            color: Colors.white,
<<<<<<< HEAD
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
=======
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem("checkout", _countStatus("checkout")),
                _buildTabItem("proses", _countStatus("proses")),
                _buildTabItem("selesai", _countStatus("selesai")),
              ],
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
            ),
          ),

          // ── List Pesanan ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
<<<<<<< HEAD
                    child: CircularProgressIndicator(
                        color: Color(0xFF2E9900)))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_late_outlined,
                                size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text("Belum ada pesanan '$_activeTab'",
                                style:
                                    const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF2E9900),
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) =>
                              _buildOrderCard(filtered[i]),
                        ),
                      ),
=======
                    child: CircularProgressIndicator(color: Color(0xFF2E9900)),
                  )
                : filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada pesanan di tab $_activeTab",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // ── Tab item ───────────────────────────────────────────────────────────────
  Widget _buildTabItem(_TabConfig tab, int count) {
    final isActive = _activeTab == tab.label;
=======
  // Helper untuk menghitung jumlah pesanan per status
  String _countStatus(String status) {
    int count = _allOrders
        .where((o) => o.status.toLowerCase() == status.toLowerCase())
        .length;
    return count.toString();
  }

  Widget _buildTabItem(String title, String count) {
    bool isActive = _activeTab == title;
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab.label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? tab.color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
<<<<<<< HEAD
              tab.label,
=======
              title,
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
              style: TextStyle(
                color: isActive ? tab.color : Colors.grey,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tab.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
<<<<<<< HEAD
                  '$count',
                  style: TextStyle(
                      fontSize: 10,
                      color: tab.color,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
=======
                  count,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
          ],
        ),
      ),
    );
  }

  // ── Order Card ─────────────────────────────────────────────────────────────
  Widget _buildOrderCard(OrderModel order) {
<<<<<<< HEAD
    final tabConfig = _tabs.firstWhere(
      (t) => t.label.toLowerCase() == _activeTab.toLowerCase(),
      orElse: () => _tabs[0],
    );

    // Tentukan tombol aksi berdasarkan tab aktif
    Widget? actionButtons;
    if (_activeTab == 'Tertunda') {
      actionButtons = Row(
        children: [
          // Terima → Pengolahan
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(order, 'Pengolahan'),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Terima'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9900),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Batalkan
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _updateStatus(order, 'Dibatalkan'),
              icon: const Icon(Icons.close_rounded,
                  size: 16, color: Color(0xFFEF4444)),
              label: const Text('Batalkan',
                  style: TextStyle(color: Color(0xFFEF4444))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
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
          // Selesaikan → Selesai
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(order, 'Selesai'),
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: const Text('Selesai'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9900),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Batalkan
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _updateStatus(order, 'Dibatalkan'),
              icon: const Icon(Icons.close_rounded,
                  size: 16, color: Color(0xFFEF4444)),
              label: const Text('Batalkan',
                  style: TextStyle(color: Color(0xFFEF4444))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      );
    }
    // Tab Selesai & Dibatalkan tidak ada tombol aksi
=======
    Color statusColor = _activeTab == "Tertunda"
        ? Colors.red
        : (_activeTab == "Pengolahan" ? Colors.orange : Colors.green);

    String btnLabel = _activeTab == "Tertunda" ? "Menerima" : "Siap";
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
<<<<<<< HEAD
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
=======
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          // Header baris: badge status + tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nomor order + nama pelanggan
          Text(
            'Order #${order.idOrder}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
=======
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      order.dateOrdered,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Order #${order.idOrder}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Pelanggan : ${order.customerName}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Rp ${order.totalPrice}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_activeTab != "Selesai")
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implementasi Update Status ke DB
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9900),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          btnLabel,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    OutlinedButton(
                      onPressed: () {
                        // Aksi lihat detail
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Detail",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Gambar Placeholder karena di tabel order biasanya tidak ada gambar produk langsung
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.grey,
              size: 40,
            ),
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237
          ),
          Text(
            'Pelanggan: ${order.customerName}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 6),

          // Metode pembayaran & ambil
          Row(
            children: [
              const Icon(Icons.payment_rounded,
                  size: 14, color: Colors.blueGrey),
              const SizedBox(width: 4),
              Text(
                '${order.metodePembayaran}  •  ${order.metodeAmbil}',
                style:
                    const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total harga
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  color: Colors.green, size: 18),
              const SizedBox(width: 5),
              Text(
                'Rp ${order.totalPrice}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),

          // Tombol aksi (jika ada)
          if (actionButtons != null) ...[
            const SizedBox(height: 12),
            actionButtons,
          ],
        ],
      ),
    );
  }
}
<<<<<<< HEAD

// ── Helper: cocokkan label tab (UI) dengan nilai status di DB ─────────────────
// Label 'Diproses' di UI → nilai 'Pengolahan' di database
bool _matchStatus(String dbStatus, String tabLabel) {
  final s = dbStatus.toLowerCase();
  switch (tabLabel) {
    case 'Tertunda':   return s == 'tertunda';
    case 'Diproses':   return s == 'pengolahan';  // DB value tetap 'Pengolahan'
    case 'Selesai':    return s == 'selesai';
    case 'Dibatalkan': return s == 'dibatalkan';
    default:           return s == tabLabel.toLowerCase();
  }
}

// ── Helper class untuk konfigurasi tab ────────────────────────────────────────
class _TabConfig {
  final String label;
  final Color color;
  final Color bgColor;
  const _TabConfig(this.label, this.color, this.bgColor);
}
=======
>>>>>>> 8fc1f8d548a1adf13c785c5dac3f0a936e9ad237

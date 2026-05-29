import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class CompletedOrderItem {
  final int idDetail;
  final int idProduct;
  final String namaProduk;
  final int jumlah;
  final int hargaSatuan;
  final int subtotal;

  const CompletedOrderItem({
    required this.idDetail,
    required this.idProduct,
    required this.namaProduk,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory CompletedOrderItem.fromJson(Map<String, dynamic> j) =>
      CompletedOrderItem(
        idDetail: (j['id_detail'] as num).toInt(),
        idProduct: (j['id_product'] as num).toInt(),
        namaProduk: j['nama_produk'] as String? ?? '-',
        jumlah: (j['jumlah'] as num).toInt(),
        hargaSatuan: (j['harga_satuan'] as num?)?.toInt() ?? 0,
        subtotal: (j['subtotal'] as num).toInt(),
      );
}

class CompletedOrder {
  final int idOrder;
  final String namaPembeli;
  final String tanggalPesan;
  final String metodePembayaran;
  final String metodeAmbil;
  final List<CompletedOrderItem> items;
  final int totalPesanan;

  const CompletedOrder({
    required this.idOrder,
    required this.namaPembeli,
    required this.tanggalPesan,
    required this.metodePembayaran,
    required this.metodeAmbil,
    required this.items,
    required this.totalPesanan,
  });

  factory CompletedOrder.fromJson(Map<String, dynamic> j) => CompletedOrder(
        idOrder: (j['id_order'] as num).toInt(),
        namaPembeli: j['nama_pembeli'] as String? ?? '-',
        tanggalPesan: j['tanggal_pesan'] as String? ?? '-',
        metodePembayaran: j['metode_pembayaran'] as String? ?? '-',
        metodeAmbil: j['metode_ambil'] as String? ?? '-',
        items: (j['items'] as List<dynamic>)
            .map((e) => CompletedOrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalPesanan: (j['total_pesanan'] as num).toInt(),
      );
}

class CompletedOrdersResult {
  final int totalCount;
  final int grandTotal;
  final List<CompletedOrder> orders;

  const CompletedOrdersResult({
    required this.totalCount,
    required this.grandTotal,
    required this.orders,
  });

  factory CompletedOrdersResult.fromJson(Map<String, dynamic> j) =>
      CompletedOrdersResult(
        totalCount: (j['total_count'] as num).toInt(),
        grandTotal: (j['grand_total'] as num).toInt(),
        orders: (j['orders'] as List<dynamic>)
            .map((e) => CompletedOrder.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Fetch
// ─────────────────────────────────────────────────────────────────────────────

Future<CompletedOrdersResult> fetchCompletedOrders() async {
  final data = await ApiService().getCompletedOrders();
  if (data['success'] != true) {
    throw Exception(data['message'] ?? 'Response tidak valid');
  }
  return CompletedOrdersResult.fromJson(data);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _formatRupiah(int value) {
  if (value >= 1000000000) {
    return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000000) {
    return 'Rp ${(value / 1000000).toStringAsFixed(1)}Jt';
  }
  if (value >= 1000) {
    final s = value.toString();
    final buf = StringBuffer('Rp ');
    int rem = s.length % 3;
    if (rem != 0) {
      buf.write(s.substring(0, rem));
      if (s.length > rem) buf.write('.');
    }
    for (int i = rem; i < s.length; i += 3) {
      buf.write(s.substring(i, i + 3));
      if (i + 3 < s.length) buf.write('.');
    }
    return buf.toString();
  }
  return 'Rp $value';
}

String _formatTanggal(String raw) {
  try {
    final dt = DateTime.parse(raw);
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${bulan[dt.month]} ${dt.year}, $h:$m';
  } catch (_) {
    return raw;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class CompletedOrdersPage extends StatefulWidget {
  const CompletedOrdersPage({super.key});

  @override
  State<CompletedOrdersPage> createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<CompletedOrdersPage> {
  late Future<CompletedOrdersResult> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchCompletedOrders();
  }

  void _refresh() => setState(() => _future = fetchCompletedOrders());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F6B00),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rincian Pesanan Selesai',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          // ── Tombol Refresh ──────────────────────────────────────────────────
          IconButton(
            tooltip: 'Refresh data',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF2E9900),
        onRefresh: () async {
          _refresh();
          // Berikan return value berupa objek kosong jika terjadi error saat refresh
          await _future.catchError((_) {
            return const CompletedOrdersResult(
              totalCount: 0,
              grandTotal: 0,
              orders: [],
            );
          });
        },

        child: FutureBuilder<CompletedOrdersResult>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingView();
            }
            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final data = snapshot.data!;
            if (data.orders.isEmpty) {
              return const _EmptyView();
            }

            return CustomScrollView(
              slivers: [
                // ── Banner Grand Total ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: _GrandTotalBanner(
                    grandTotal: data.grandTotal,
                    totalCount: data.totalCount,
                  ),
                ),

                // ── List Pesanan ────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _OrderCard(
                        order: data.orders[index],
                        index: index + 1,
                      ),
                      childCount: data.orders.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grand Total Banner
// ─────────────────────────────────────────────────────────────────────────────

class _GrandTotalBanner extends StatelessWidget {
  final int grandTotal;
  final int totalCount;

  const _GrandTotalBanner({
    required this.grandTotal,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F6B00), Color(0xFF3DB800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E9900).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Total Pendapatan Keseluruhan',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatRupiah(grandTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      '$totalCount Pesanan Selesai',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'Dihitung dari harga asli produk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final CompletedOrder order;
  final int index;

  const _OrderCard({required this.order, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDFEFDF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E9900).withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FAF0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E9900).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#$index',
                      style: const TextStyle(
                        color: Color(0xFF1F6B00),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Pesanan #${order.idOrder}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF1A2E1A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E9900)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '✓ Selesai',
                              style: TextStyle(
                                color: Color(0xFF1F6B00),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTanggal(order.tanggalPesan),
                        style: const TextStyle(
                          color: Color(0xFF8A9E8A),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Info Pembeli ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.person_rounded,
                    size: 14, color: Color(0xFF8A9E8A)),
                const SizedBox(width: 5),
                Text(
                  order.namaPembeli,
                  style: const TextStyle(
                    color: Color(0xFF3D553D),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.payment_rounded,
                    size: 14, color: Color(0xFF8A9E8A)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    order.metodePembayaran,
                    style: const TextStyle(
                        color: Color(0xFF3D553D), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1, color: Color(0xFFE8F4E8)),
          ),

          // ── Item List ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: order.items
                  .map((item) => _ItemRow(item: item))
                  .toList(),
            ),
          ),

          // ── Footer: Total ────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2E1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded,
                        color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Total Pesanan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatRupiah(order.totalPesanan),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item Row
// ─────────────────────────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final CompletedOrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2E9900).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF2E9900),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaProduk,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2E1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.jumlah} x ${_formatRupiah(item.hargaSatuan)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A9E8A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatRupiah(item.subtotal),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E9900),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / Error / Empty views
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2E9900),
            strokeWidth: 3,
          ),
          SizedBox(height: 14),
          Text(
            'Memuat rincian pesanan…',
            style: TextStyle(color: Color(0xFF8A9E8A), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: Color(0xFFD32F2F), size: 52),
            const SizedBox(height: 14),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF1A2E1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Periksa koneksi dan server',
              style: TextStyle(
                color: const Color(0xFF1A2E1A).withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9900),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              color: Color(0xFFB0C4B0), size: 64),
          SizedBox(height: 14),
          Text(
            'Belum ada pesanan selesai',
            style: TextStyle(
              color: Color(0xFF8A9E8A),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
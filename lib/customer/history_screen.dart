import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/customer/order_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _history = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
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

      // Coba ambil semua order (termasuk status 'keranjang' dan 'checkout')
      // Jika API hanya punya getHistory, kita gunakan itu.
      // Jika ada getAllOrders atau getOrdersByUser, gunakan itu.
      List<dynamic> data = [];
      try {
        // Prioritas: coba method yang mengambil semua order user
        data = await _api.getOrdersByUser(_userId);
      } catch (_) {
        // Fallback ke getHistory jika method di atas tidak ada
        data = await _api.getHistory(_userId);
      }

      if (mounted) {
        // Urutkan dari yang terbaru
        data.sort((a, b) {
          final tA = DateTime.tryParse(a['tanggal_pesan'] ?? '') ??
              DateTime(2000);
          final tB = DateTime.tryParse(b['tanggal_pesan'] ?? '') ??
              DateTime(2000);
          return tB.compareTo(tA);
        });

        setState(() {
          _history = data;
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

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final double nilai = double.tryParse(harga.toString()) ?? 0;
    return nilai
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
      return '${dt.day} ${bulan[dt.month]} ${dt.year} • $jam:$menit WIB';
    } catch (_) {
      return tanggal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E9900),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E9900)),
      );
    }

    if (_userId == 0) {
      return const Center(
        child: Text('Silakan login terlebih dahulu',
            style: TextStyle(color: Colors.grey)),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Tidak dapat memuat riwayat',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9900)),
              onPressed: _loadHistory,
              child: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Belum ada riwayat pesanan',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9900),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.white),
              label: const Text('Mulai Belanja',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2E9900),
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final order = _history[index];
          final items = order['items'] as List? ?? [];

          // Label nama produk (ringkas)
          final firstItem =
              items.isNotEmpty ? (items[0]['nama_produk'] ?? '-') : 'Produk';
          final itemLabel = items.length > 1
              ? '$firstItem (+${items.length - 1} lainnya)'
              : firstItem;

          return OrderCard(
            orderId: order['id_order']?.toString() ?? '-',
            status: _labelStatus(order['status']),
            date: _formatTanggal(order['tanggal_pesan']),
            itemName: itemLabel,
            price: _formatHarga(order['total_harga']),
            statusColor: _warnaStatus(order['status']),
            items: items,
            metodePembayaran: order['metode_pembayaran']?.toString(),
            metodeAmbil: order['metode_ambil']?.toString(),
            onPesanLagi: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          );
        },
      ),
    );
  }

  String _labelStatus(dynamic status) {
    switch (status?.toString()) {
      case 'checkout':
        return 'Selesai';
      case 'keranjang':
        return 'Diproses';
      default:
        return status?.toString() ?? '-';
    }
  }

  Color _warnaStatus(dynamic status) {
    switch (status?.toString()) {
      case 'checkout':
        return const Color(0xFF2E9900);
      case 'keranjang':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
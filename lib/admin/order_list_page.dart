import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/modelsadmin/order_model.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  String _activeTab = "Tertunda";
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Fungsi untuk mengambil data dari API
  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      // Pastikan fungsi ini sudah kamu buat di ApiService
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

  @override
  Widget build(BuildContext context) {
    // Memfilter list berdasarkan tab yang aktif
    List<OrderModel> filteredOrders = 
        _allOrders.where((o) => o.status.toLowerCase() == _activeTab.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          // HEADER HIJAU
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 40, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF2E9900),
            ),
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
                    Text("MbahMeth", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("Portal Admin", 
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadOrders, // Tombol refresh data
                ),
              ],
            ),
          ),

          // TAB BAR
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem("Tertunda", _countStatus("Tertunda")),
                _buildTabItem("Pengolahan", _countStatus("Pengolahan")),
                _buildTabItem("Selesai", _countStatus("Selesai")),
              ],
            ),
          ),

          // LIST PESANAN
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E9900)))
              : filteredOrders.isEmpty 
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text("Belum ada pesanan di tab $_activeTab", style: const TextStyle(color: Colors.grey)),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Helper untuk menghitung jumlah pesanan per status
  String _countStatus(String status) {
    int count = _allOrders.where((o) => o.status.toLowerCase() == status.toLowerCase()).length;
    return count.toString();
  }

  Widget _buildTabItem(String title, String count) {
    bool isActive = _activeTab == title;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF2E9900) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(title, 
              style: TextStyle(
                color: isActive ? const Color(0xFF2E9900) : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            if (count != "0")
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(count, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor = _activeTab == "Tertunda" ? Colors.red : 
                        (_activeTab == "Pengolahan" ? Colors.orange : Colors.green);
    
    String btnLabel = _activeTab == "Tertunda" ? "Menerima" : "Siap";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(order.status.toUpperCase(), 
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Text(order.dateOrdered, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Order #${order.idOrder}", 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("Pelanggan : ${order.customerName}", 
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: Colors.green, size: 18),
                    const SizedBox(width: 5),
                    Text("Rp ${order.totalPrice}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(btnLabel, style: const TextStyle(color: Colors.white)),
                      ),
                    OutlinedButton(
                      onPressed: () {
                        // Aksi lihat detail
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Detail", style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                )
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
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 40),
          ),
        ],
      ),
    );
  }
}
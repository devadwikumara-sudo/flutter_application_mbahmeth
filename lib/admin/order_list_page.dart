import 'package:flutter/material.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  String _activeTab = "Tertunda";

  // Perbaikan Data dummy: Gunakan String Path saja untuk gambar
  final List<Map<String, dynamic>> _allOrders = [
    {
      "id": "Insekti-200ec-001",
      "customer": "Purbaya",
      "price": "18.000",
      "time": "2 menit lalu",
      "status": "Tertunda",
      "img": "https://via.placeholder.com/100" // Ini URL
    },
    {
      "id": "Pupuk-KNO M-002",
      "customer": "Bahlil",
      "price": "18.250",
      "time": "15 menit lalu",
      "status": "Tertunda",
      "img": "assets/images/kno_merah.png", // Ini Path Local
    },
    {
      "id": "Bibit-Perkasa-003",
      "customer": "Kaesang",
      "price": "64.000",
      "time": "42 menit lalu",
      "status": "Tertunda",
      "img": "https://via.placeholder.com/100"
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = 
        _allOrders.where((o) => o['status'] == _activeTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          // HEADER HIJAU DENGAN TOMBOL BACK
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 40, 20, 20), // Sesuaikan padding atas untuk status bar
            decoration: const BoxDecoration(
              color: Color(0xFF2E9900),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context), // Biar bisa balik ke Dashboard
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.eco, color: Color(0xFF2E9900)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("MbahMeth", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("Portal Admin", 
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
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
                _buildTabItem("Tertunda", "${_allOrders.where((o) => o['status'] == "Tertunda").length}"),
                _buildTabItem("Pengolahan", "0"),
                _buildTabItem("Selesai", "0"),
              ],
            ),
          ),

          // LIST PESANAN
          Expanded(
            child: filteredOrders.isEmpty 
              ? const Center(child: Text("Belum ada pesanan"))
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

  Widget _buildOrderCard(Map<String, dynamic> data) {
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
                      child: Text(data['status'].toUpperCase(), 
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Text(data['time'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Order #${data['id']}", 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("Pelanggan : ${data['customer']}", 
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: Colors.green, size: 18),
                    const SizedBox(width: 5),
                    Text("Rp. ${data['price']}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_activeTab != "Selesai")
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9900),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(btnLabel, style: const TextStyle(color: Colors.white)),
                      ),
                    OutlinedButton(
                      onPressed: () {},
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
          // LOGIKA TAMPILAN GAMBAR (Penting!)
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: data['img'].toString().startsWith('assets') 
                ? Image.asset(data['img'], fit: BoxFit.cover)
                : Image.network(data['img'], fit: BoxFit.cover, 
                    errorBuilder: (c, e, s) => const Icon(Icons.inventory_2, color: Colors.grey, size: 40)),
            ),
          ),
        ],
      ),
    );
  }
}
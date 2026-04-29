import 'package:flutter/material.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  // Status: Tertunda, Pengolahan, Selesai
  String _activeTab = "Tertunda";

  // Data dummy
  final List<Map<String, dynamic>> _allOrders = [
    {
      "id": "Insekti-200ec-001",
      "customer": "Purbaya",
      "price": "18.000",
      "time": "2 menit lalu",
      "status": "Tertunda",
      "img": "https://via.placeholder.com/100" // Nanti ganti path asetmu
    },
    {
      "id": "Pupuk-KNO M-002",
      "customer": "Bahlil",
      "price": "18.250",
      "time": "15 menit lalu",
      "status": "Tertunda",
      "img": "https://via.placeholder.com/100"
    },
    {
      "id": "Bibit-Perkasa-003",
      "customer": "Kaesang",
      "price": "64.000",
      "time": "42 menit lalu",
      "status": "Tertunda",
      "img": "https://via.placeholder.com/100"
    },
    // Contoh data untuk tab lain
    {
      "id": "Insekti-200ec-001",
      "customer": "Purbaya",
      "price": "26.000",
      "time": "2 menit lalu",
      "status": "Pengolahan",
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
          // HEADER HIJAU
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF2E9900),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Row(
              children: [
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

          // TAB BAR DENGAN BADGE
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem("Tertunda", ""),
                _buildTabItem("Pengolahan", ""),
                _buildTabItem("Selesai", ""),
              ],
            ),
          ),

          // LIST PESANAN
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(filteredOrders[index]);
              },
            ),
          ),
        ],
      ),
      
      // BOTTOM NAVIGATION BAR

    );
  }

  // Widget untuk Tab Item
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
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Text(count, style: const TextStyle(fontSize: 10, color: Colors.brown)),
            )
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Pesanan
  Widget _buildOrderCard(Map<String, dynamic> data) {
  Color statusColor = _activeTab == "Tertunda" ? Colors.red : 
                      (_activeTab == "Pengolahan" ? Colors.orange : Colors.green);
  String btnLabel = _activeTab == "Tertunda" ? "Menerima" : "Siap";

  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(16), // Padding diperbesar biar lega
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PAKAI EXPANDED: Biar teks tahu batas lebarnya dan tidak meluber
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
              // Tambahkan overflow: TextOverflow.ellipsis biar kalau kepanjangan jadi titik-titik
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
              // Tombol-tombol
              Wrap( // Pakai Wrap biar kalau layar kecil tombolnya otomatis pindah ke bawah (tidak overflow)
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_activeTab != "Selesai")
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E9900),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(btnLabel, style: const TextStyle(color: Colors.white)),
                    ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text("Detail", style: TextStyle(color: Colors.grey)),
                  ),
                ],
              )
            ],
          ),
        ),
        
        const SizedBox(width: 12),

        // GANTI GAMBAR DENGAN ICON (Biar nggak error HTTP di Web)
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.inventory_2, color: Colors.grey, size: 40),
        ),
      ],
    ),
  );
}
}

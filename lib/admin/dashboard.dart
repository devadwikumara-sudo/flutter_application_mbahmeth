import 'package:flutter/material.dart';
import 'users_semua.dart';
// Import halaman yang sudah kamu buat
import 'package:flutter_application_mbahmeth/admin/admin_crud/presentation/pages/product_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/admin_orders/presentation/pages/order_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text.rich(
                TextSpan(
                  text: "Selamat datang,\n",
                  style: TextStyle(fontSize: 16),
                  children: [
                    TextSpan(
                      text: "Admin Mbah Met",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Statistik Toko", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: const [
                InfoCard("Total Pengguna", "15,284"),
                InfoCard("Total Produk", "1,837"),
                InfoCard("Total Pesanan", "8,492"),
                InfoCard("Pendapatan", "Rp1.145,928"),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Menu Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            // NAVIGASI: KELOLA PENGGUNA
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersSemua()));
              },
              child: const MenuCard(
                title: "Kelola Pengguna",
                subtitle: "Lihat dan edit akun pengguna",
                icon: Icons.people_alt_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // NAVIGASI: KELOLA PRODUK (CRUD)
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListPage()));
              },
              child: const MenuCard(
                title: "Kelola Produk",
                subtitle: "Tambah, edit, atau hapus produk",
                icon: Icons.inventory_2_outlined,
                color: Colors.green,
                textWhite: true,
              ),
            ),
            const SizedBox(height: 12),

            // NAVIGASI: KELOLA PESANAN (ORDER LIST)
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderListPage()));
              },
              child: const MenuCard(
                title: "Kelola Pesanan",
                subtitle: "Memproses pesanan pelanggan",
                icon: Icons.receipt_long_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVBAR SINKRONISASI
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) { // Icon List Alt -> Ke Order List
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderListPage()));
          } else if (index == 2) { // Icon Edit -> Ke CRUD Produk
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListPage()));
          } else if (index == 3) { // Icon Inventory -> Ke CRUD Produk
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListPage()));
          } else if (index == 4) { // Icon Person -> Ke Users
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersSemua()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Edit"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Produk"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Akun"),
        ],
      ),
    );
  }
}

// Widget Pendukung
class InfoCard extends StatelessWidget {
  final String title, value;
  const InfoCard(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.green)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final bool textWhite;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.textWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = textWhite ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: textWhite ? Colors.white24 : Colors.green.shade50, child: Icon(icon, color: textWhite ? Colors.white : Colors.green)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: textColor),
        ],
      ),
    );
  }
}
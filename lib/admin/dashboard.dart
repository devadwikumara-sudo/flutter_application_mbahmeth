import 'package:flutter/material.dart';
import 'users_semua.dart';
import 'package:flutter_application_mbahmeth/admin/admin_crud/presentation/pages/product_list_page.dart';
// Import halaman yang sudah kamu buat
import 'package:flutter_application_mbahmeth/admin/admin_crud/presentation/pages/product_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/admin_orders/presentation/pages/order_list_page.dart';

// ===== HALAMAN DUMMY =====
class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Halaman Pesanan"));
  }
}

class ProfilAdmin extends StatelessWidget {
  const ProfilAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Halaman Profil"));
  }
}

// ================= MAIN =================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminDashboard(),
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AdminDashboard(),
    );
  }
}

// ================= DASHBOARD =================
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    _homePage(),
    const PesananPage(),
    const UsersSemua(),
    const ProductListPage(),
    const ProfilAdmin(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "User"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Stok"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }

  // ================= HOME =================
  Widget _homePage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
=======
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
            // ===== BANNER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
=======
            const Text("Statistik Toko", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            // ===== GRID =====
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: const [
                InfoCard("Total Pengguna", "15,284", Icons.groups_outlined, "+2.4%"),
                InfoCard("Total Produk", "1,837", Icons.inventory_2_outlined, "+5.1%"),
                InfoCard("Total Pesanan", "8,492", Icons.receipt_long_outlined, "+3.7%"),
                InfoCard("Pendapatan", "Rp145.928", Icons.show_chart, "+8.2%"),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Menu cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            // ===== MENU =====
            GestureDetector(
              onTap: () => setState(() => currentIndex = 2),
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
                icon: Icons.edit_outlined,
                color: Color(0xFFD4F5CC),
                iconBgColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => setState(() => currentIndex = 3),
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
                iconBgColor: Colors.white24,
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

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => setState(() => currentIndex = 1),
              child: const MenuCard(
                title: "Kelola Pesanan",
                subtitle: "Memproses pesanan",
                icon: Icons.receipt_long_outlined,
                color: Color(0xFFD4F5CC),
                iconBgColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // ===== 🔥 UMPAN BALIK =====
            GestureDetector(
              onTap: () => setState(() => currentIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E9900),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Umpan Balik Pelanggan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4DBE2E),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "3",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
=======

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

// ================= WIDGET =================
class InfoCard extends StatelessWidget {
  final String title, value, percentage;
  final IconData icon;

  const InfoCard(this.title, this.value, this.icon, this.percentage, {super.key});
// Widget Pendukung
class InfoCard extends StatelessWidget {
  final String title, value;
  const InfoCard(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4F5CC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(icon, color: Colors.green, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(percentage, style: const TextStyle(fontSize: 10)),
            ],
          ),
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
  final Color iconBgColor;
  final bool textWhite;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconBgColor,
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
                Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)),
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
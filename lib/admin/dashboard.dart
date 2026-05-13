import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/admin/admin_crud/presentation/pages/product_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/admin_orders/presentation/pages/order_list_page.dart';

// Import halaman sesuai struktur folder kelompok (Gambar B6049AAB)
import 'users_semua.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MbahMeth Admin',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true, // Menggunakan desain Material 3 yang lebih modern
      ),

      home: const AdminDashboard(),
    );
  }
}

// Widget untuk Profil Admin
class ProfilAdmin extends StatelessWidget {
  const ProfilAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Halaman Profil Admin")));
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 0;

  // Daftar halaman yang akan ditampilkan di Bottom Navigation
  late final List<Widget> pages = [
    _homePage(), // Index 0
    OrderListPage(), // Index 1
    const UsersSemua(), // Index 2
    const ProductListPage(), // Index 3
    const ProfilAdmin(), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Pesanan"),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: "User",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: "Stok",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  // Tampilan Utama (Home) Dashboard
  Widget _homePage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => currentIndex = 4), // Pindah ke profil
              child: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Selamat Datang
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
                  style: TextStyle(fontSize: 16, color: Colors.green),
                  children: [
                    TextSpan(
                      text: "Admin Mbah Met",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Statistik Toko",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Grid Statistik
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: const [
                InfoCard(
                  "Total Pengguna",
                  "15,284",
                  Icons.groups_outlined,
                  "+2.4%",
                ),
                InfoCard(
                  "Total Produk",
                  "1,837",
                  Icons.inventory_2_outlined,
                  "+5.1%",
                ),
                InfoCard(
                  "Total Pesanan",
                  "8,492",
                  Icons.receipt_long_outlined,
                  "+3.7%",
                ),
                InfoCard("Pendapatan", "Rp145.928", Icons.show_chart, "+8.2%"),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              "Menu Cepat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Daftar Menu Card
            MenuCard(
              onTap: () => setState(() => currentIndex = 2),
              title: "Kelola Pengguna",
              subtitle: "Lihat dan edit akun pengguna",
              icon: Icons.edit_outlined,
              color: const Color(0xFFD4F5CC),
              iconBgColor: Colors.white,
            ),
            const SizedBox(height: 12),
            MenuCard(
              onTap: () => setState(() => currentIndex = 3),
              title: "Kelola Produk",
              subtitle: "Tambah, edit, atau hapus produk",
              icon: Icons.inventory_2_outlined,
              color: Colors.green,
              textWhite: true,
              iconBgColor: Colors.white24,
            ),
            const SizedBox(height: 12),
            MenuCard(
              onTap: () => setState(() => currentIndex = 1),
              title: "Kelola Pesanan",
              subtitle: "Memproses pesanan pelanggan",
              icon: Icons.receipt_long_outlined,
              color: Colors.white,
              iconBgColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen Card Informasi Statistik
class InfoCard extends StatelessWidget {
  final String title, value, percentage;
  final IconData icon;

  const InfoCard(
    this.title,
    this.value,
    this.icon,
    this.percentage, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Komponen Card Menu Navigasi
class MenuCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color, iconBgColor;
  final bool textWhite;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconBgColor,
    required this.onTap,
    this.textWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = textWhite ? Colors.white : Colors.black;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconBgColor,
              child: Icon(icon, color: textWhite ? Colors.white : Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textColor),
          ],
        ),
      ),
    );
  }
}

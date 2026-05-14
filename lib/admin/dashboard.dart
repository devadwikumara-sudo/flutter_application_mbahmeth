import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/admin/admin_crud/presentation/pages/product_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/admin_orders/presentation/pages/order_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/profil_admin.dart'; // <-- HUBUNGKAN KE PROFIL ADMIN
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
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    _homePage(),
    const OrderListPage(),
    const UsersSemua(),
    const ProductListPage(),
    const ProfilAdmin(), // <-- HALAMAN PROFIL ASLI
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Pesanan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: "User",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: "Produk",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  // ================= HOME PAGE =================

  Widget _homePage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,

        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  currentIndex = 4;
                });
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= WELCOME =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Admin Mbah Met",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= STATISTIK =================

            const Text(
              "Statistik Toko",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,

              children: const [
                InfoCard(
                  title: "Total Pengguna",
                  value: "15,284",
                  icon: Icons.groups_outlined,
                  percentage: "+2.4%",
                ),

                InfoCard(
                  title: "Total Produk",
                  value: "1,837",
                  icon: Icons.inventory_2_outlined,
                  percentage: "+5.1%",
                ),

                InfoCard(
                  title: "Total Pesanan",
                  value: "8,492",
                  icon: Icons.receipt_long_outlined,
                  percentage: "+3.7%",
                ),

                InfoCard(
                  title: "Pendapatan",
                  value: "Rp145.928",
                  icon: Icons.show_chart,
                  percentage: "+8.2%",
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= MENU CEPAT =================

            const Text(
              "Menu Cepat",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            MenuCard(
              title: "Kelola Pengguna",
              subtitle: "Lihat dan edit akun pengguna",
              icon: Icons.people_outline,
              color: const Color(0xFFD4F5CC),
              iconBgColor: Colors.white,

              onTap: () {
                setState(() {
                  currentIndex = 2;
                });
              },
            ),

            const SizedBox(height: 12),

            MenuCard(
              title: "Kelola Produk",
              subtitle: "Tambah, edit, atau hapus produk",
              icon: Icons.inventory_2_outlined,
              color: Colors.green,
              iconBgColor: Colors.white24,
              textWhite: true,

              onTap: () {
                setState(() {
                  currentIndex = 3;
                });
              },
            ),

            const SizedBox(height: 12),

            MenuCard(
              title: "Kelola Pesanan",
              subtitle: "Memproses pesanan pelanggan",
              icon: Icons.receipt_long_outlined,
              color: Colors.white,
              iconBgColor: Colors.green,

              onTap: () {
                setState(() {
                  currentIndex = 1;
                });
              },
            ),

            const SizedBox(height: 12),

            MenuCard(
              title: "Profil Admin",
              subtitle: "Kelola akun administrator",
              icon: Icons.person_outline,
              color: Colors.white,
              iconBgColor: Colors.green,

              onTap: () {
                setState(() {
                  currentIndex = 4;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= INFO CARD =================

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.green.shade50,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: Colors.green,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

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

// ================= MENU CARD =================

class MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconBgColor;
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
      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),

        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconBgColor,

              child: Icon(
                icon,
                color: textWhite ? Colors.white : Colors.green,
              ),
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

                  const SizedBox(height: 2),

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

            Icon(
              Icons.chevron_right,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}
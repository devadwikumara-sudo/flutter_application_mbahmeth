import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_mbahmeth/admin/admin_crud/presentation/pages/product_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/order_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/profil_admin.dart';
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';
import 'users_semua.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model statistik dashboard
// ─────────────────────────────────────────────────────────────────────────────

class DashboardStats {
  final int totalUsers;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;

  const DashboardStats({
    required this.totalUsers,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      // FIX: Gunakan key 'total_products' yang dihitung dari COUNT(*) tabel products
      totalProducts: (json['total_products'] as num?)?.toInt() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String formatRevenue(double value) {
    if (value >= 1000000000) return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    if (value >= 1000000) return 'Rp ${(value / 1000000).toStringAsFixed(1)}Jt';
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)}K';
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  static String formatNumber(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fetch helper — dipanggil dari FutureBuilder
// ─────────────────────────────────────────────────────────────────────────────

Future<DashboardStats> fetchDashboardStats() async {
  final url = Uri.parse('${AppConfig.baseUrl}/admin/dashboard_stats.php');
  final response = await http.get(url).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Server error: ${response.statusCode}');
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (body['success'] != true) {
    throw Exception(body['message'] ?? 'Response tidak valid');
  }

  return DashboardStats.fromJson(body);
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminDashboard — shell dengan BottomNav
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  void _navigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomePage(onNavigate: _navigate),
      OrderListPage(),
      const UsersSemua(),
      const ProductListPage(),
      const ProfilAdmin(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _navigate,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomNav
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E9900).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: const Color(0xFF2E9900),
          unselectedItemColor: const Color(0xFFB0C4B0),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: "Pesanan"),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people_rounded), label: "User"),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2_rounded), label: "Produk"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: "Profil"),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HomePage — StatefulWidget dengan FutureBuilder
// ─────────────────────────────────────────────────────────────────────────────

class _HomePage extends StatefulWidget {
  final void Function(int) onNavigate;

  const _HomePage({required this.onNavigate});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = fetchDashboardStats();
  }

  void _retry() {
    setState(() {
      _statsFuture = fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF2),
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F6B00), Color(0xFF2E9900)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  "MbahMeth Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () => widget.onNavigate(4),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          // ── Body ──────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _WelcomeBanner(),
                const SizedBox(height: 28),
                const _SectionLabel(label: "Statistik Toko", icon: Icons.bar_chart_rounded),
                const SizedBox(height: 14),

                FutureBuilder<DashboardStats>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const _StatsSkeleton();
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return _StatsError(
                            message: snapshot.error.toString(),
                            onRetry: _retry,
                          );
                        }
                        return _StatsGrid(stats: snapshot.data!);
                      default:
                        return const _StatsSkeleton();
                    }
                  },
                ),

                const SizedBox(height: 32),
                const _SectionLabel(label: "Menu Cepat", icon: Icons.grid_view_rounded),
                const SizedBox(height: 14),
                _QuickMenu(onNavigate: widget.onNavigate),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WelcomeBanner
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            color: const Color(0xFF2E9900).withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat Datang,",
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Admin Mbah Met 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "🌿 Toko Pertanian Terpercaya",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionLabel
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2E9900).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2E9900), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2E1A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatsGrid — REDESIGNED: 2 kartu besar atas + 2 kartu horizontal bawah
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Baris 1: Pendapatan (lebar penuh, paling menonjol) ──────────────
        _StatCardWide(
          label: "Total Pendapatan",
          value: DashboardStats.formatRevenue(stats.totalRevenue),
          subtitle: "Dari semua pesanan selesai",
          icon: Icons.account_balance_wallet_rounded,
          accentColor: const Color(0xFF2E9900),
          bgColor: const Color(0xFF1A2E1A),
          trendLabel: "checkout",
          trendIcon: Icons.trending_up_rounded,
        ),
        const SizedBox(height: 12),

        // ── Baris 2: 2 kartu sejajar ────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatCardSquare(
                label: "Pesanan",
                value: DashboardStats.formatNumber(stats.totalOrders),
                subtitle: "Selesai checkout",
                icon: Icons.receipt_long_rounded,
                accentColor: const Color(0xFF2E9900),
                bgColor: Colors.white,
                valueColor: const Color(0xFF1A2E1A),
                borderColor: const Color(0xFFDFEFDF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCardSquare(
                label: "Pengguna",
                value: DashboardStats.formatNumber(stats.totalUsers),
                subtitle: "Pelanggan terdaftar",
                icon: Icons.groups_rounded,
                accentColor: const Color(0xFF5CC400),
                bgColor: Colors.white,
                valueColor: const Color(0xFF1A2E1A),
                borderColor: const Color(0xFFDFEFDF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Baris 3: Produk (full-width horizontal, warna beda) ─────────────
        _StatCardHorizontal(
          label: "Total Produk",
          value: DashboardStats.formatNumber(stats.totalProducts),
          subtitle: "Item tersedia di semua kategori",
          icon: Icons.inventory_2_rounded,
          chipLabel: "4 Kategori",
          chipIcon: Icons.category_rounded,
          accentColor: const Color(0xFF1F6B00),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatCardWide — kartu lebar penuh, dark bg, untuk Revenue
// ─────────────────────────────────────────────────────────────────────────────

class _StatCardWide extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final String trendLabel;
  final IconData trendIcon;

  const _StatCardWide({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.trendLabel,
    required this.trendIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi lingkaran latar
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Label + icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Trend badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: accentColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(trendIcon, color: accentColor, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          trendLabel,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
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
// _StatCardSquare — kartu kotak putih untuk Pesanan & Pengguna
// ─────────────────────────────────────────────────────────────────────────────

class _StatCardSquare extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final Color valueColor;
  final Color borderColor;

  const _StatCardSquare({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.valueColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A2E1A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF8A9E8A),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatCardHorizontal — kartu lebar horizontal untuk Produk
// ─────────────────────────────────────────────────────────────────────────────

class _StatCardHorizontal extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final String chipLabel;
  final IconData chipIcon;
  final Color accentColor;

  const _StatCardHorizontal({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.chipLabel,
    required this.chipIcon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDFEFDF)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, const Color(0xFF3DB800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),

          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8A9E8A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF3D553D),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Nilai + chip kategori
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(chipIcon, color: accentColor, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      chipLabel,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
// _StatsSkeleton — loading placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Skeleton wide card
        Container(
          width: double.infinity,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E1A).withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2E9900)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Skeleton 2 square cards
        Row(
          children: [
            Expanded(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E9900).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E9900).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Skeleton horizontal card
        Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2E9900).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatsError
// ─────────────────────────────────────────────────────────────────────────────

class _StatsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StatsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFD32F2F), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Gagal memuat statistik",
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
                ),
                const SizedBox(height: 2),
                Text(
                  "Periksa koneksi & server",
                  style: TextStyle(
                    color: const Color(0xFFD32F2F).withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E9900),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text("Coba Lagi", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _QuickMenu
// ─────────────────────────────────────────────────────────────────────────────

class _QuickMenu extends StatelessWidget {
  final void Function(int) onNavigate;

  const _QuickMenu({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuData(title: "Kelola Pengguna", subtitle: "Lihat dan edit akun pelanggan", icon: Icons.people_rounded, accent: const Color(0xFF3DB800), index: 2),
      _MenuData(title: "Kelola Produk", subtitle: "Tambah, edit, atau hapus produk", icon: Icons.inventory_2_rounded, accent: const Color(0xFF2E9900), index: 3),
      _MenuData(title: "Kelola Pesanan", subtitle: "Proses pesanan pelanggan", icon: Icons.receipt_long_rounded, accent: const Color(0xFF1F6B00), index: 1),
      _MenuData(title: "Profil Admin", subtitle: "Kelola akun administrator", icon: Icons.manage_accounts_rounded, accent: const Color(0xFF5CC400), index: 4),
    ];

    return Column(
      children: menus
          .map((m) => _QuickMenuCard(data: m, onTap: () => onNavigate(m.index)))
          .toList(),
    );
  }
}

class _MenuData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final int index;

  const _MenuData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.index,
  });
}

class _QuickMenuCard extends StatelessWidget {
  final _MenuData data;
  final VoidCallback onTap;

  const _QuickMenuCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: data.accent.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: data.accent.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [data.accent.withOpacity(0.85), data.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: data.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1A2E1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        style: const TextStyle(color: Color(0xFF8A9E8A), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: data.accent.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded, color: data.accent, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_mbahmeth/admin/admin_crud/presentation/pages/product_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/order_list_page.dart';
import 'package:flutter_application_mbahmeth/admin/profil_admin.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'users_semua.dart';
import 'completed_orders_page.dart';

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

Future<DashboardStats> fetchDashboardStats() async {
  // FIX: Gunakan ApiService yang sudah diperbaiki dengan cache-busting & error handling
  final body = await ApiService().getDashboardStats();
  if (body['success'] != true) {
    // FIX: Tampilkan pesan error asli dari server, bukan pesan generik
    final msg = body['message'] as String? ?? 'Gagal mengambil statistik';
    throw Exception(msg);
  }
  return DashboardStats.fromJson(body);
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  // FIX: GlobalKey untuk memanggil refreshStats() saat kembali ke tab Home
  final GlobalKey<_HomePageState> _homeKey = GlobalKey<_HomePageState>();

  void _navigate(int index) {
    // FIX: Refresh statistik setiap kali tab Home (index 0) dibuka
    if (index == 0) {
      _homeKey.currentState?.refreshStats();
    }
    setState(() => _currentIndex = index);
  }

  // FIX: Logika back ditangani di onPopInvokedWithResult (PopScope)
  void _handlePop(bool didPop, dynamic result) {
    if (didPop) return;

    if (_currentIndex != 0) {
      // Kembali ke tab Home jika bukan di Home
      _homeKey.currentState?.refreshStats(); // FIX: refresh saat balik via tombol back
      setState(() => _currentIndex = 0);
      return;
    }

    // Di tab Home: tekan 2x untuk keluar
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Tekan sekali lagi untuk keluar"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F6B00),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomePage(key: _homeKey, onNavigate: _navigate), // FIX: key untuk akses refreshStats()
      // FIX: isEmbedded: true menyembunyikan tombol back di semua halaman tab
      OrderListPage(isEmbedded: true),
      const UsersSemua(isEmbedded: true),
      const ProductListPage(isEmbedded: true),
      const ProfilAdmin(isEmbedded: true),
    ];

    // FIX: PopScope menggantikan WillPopScope yang deprecated di Flutter 3.x+
    // canPop: false mencegah pop otomatis, lalu kita tangani sendiri di callback
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: _navigate,
        ),
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
            color: const Color(0xFF2E9900).withValues(alpha: 0.12),
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
// _HomePage
// ─────────────────────────────────────────────────────────────────────────────

class _HomePage extends StatefulWidget {
  final void Function(int) onNavigate;

  const _HomePage({super.key, required this.onNavigate});

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

  // FIX: Method publik dipanggil dari _AdminDashboardState saat tab Home aktif
  void refreshStats() {
    setState(() {
      _statsFuture = fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF2),
      body: RefreshIndicator(
        color: const Color(0xFF2E9900),
        onRefresh: () async {
          setState(() => _statsFuture = fetchDashboardStats());
          await _statsFuture;
        },
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
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
                Image.asset(
                  'assets/images/x2.png',
                  height: 38,
                  errorBuilder: (c, e, s) => Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            actions: [
              // ── Tombol Refresh ──────────────────────────────────────────────
              GestureDetector(
                onTap: refreshStats,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                ),
              ),
              GestureDetector(
                onTap: () => widget.onNavigate(4),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

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
                        return _StatsGrid(stats: snapshot.data!, onRefresh: refreshStats);
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
      ), // tutup RefreshIndicator
    );
  }
}
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
            color: const Color(0xFF2E9900).withValues(alpha: 0.30),
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
                    color: Colors.white.withValues(alpha: 0.20),
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
              color: Colors.white.withValues(alpha: 0.15),
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
            color: const Color(0xFF2E9900).withValues(alpha: 0.12),
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
// _StatsGrid
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardStats stats;
  // FIX: Tambah callback refresh agar tombol refresh bisa dipasang langsung di grid
  final VoidCallback onRefresh;

  const _StatsGrid({required this.stats, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Card Pendapatan: bisa diklik → halaman rincian pesanan selesai ──
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CompletedOrdersPage(),
              ),
            );
          },
          child: Stack(
            children: [
              _StatCardWide(
                label: "Total Pendapatan",
                value: DashboardStats.formatRevenue(stats.totalRevenue),
                subtitle: "Dari semua pesanan selesai  •  Tap untuk rincian",
                icon: Icons.account_balance_wallet_rounded,
                accentColor: const Color(0xFF2E9900),
                bgColor: const Color(0xFF1A2E1A),
                trendLabel: "Selesai",
                trendIcon: Icons.trending_up_rounded,
              ),
              // ── Ikon panah kecil di pojok kanan bawah sebagai hint klik ──
              Positioned(
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E9900).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCardSquare(
                label: "Pesanan",
                value: DashboardStats.formatNumber(stats.totalOrders),
                subtitle: "Pesanan selesai",
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
        _StatCardHorizontal(
          label: "Total Produk",
          value: DashboardStats.formatNumber(stats.totalProducts),
          subtitle: "Item tersedia di semua kategori",
          icon: Icons.inventory_2_rounded,
          chipLabel: "4 Kategori",
          chipIcon: Icons.category_rounded,
          accentColor: const Color(0xFF1F6B00),
        ),
        // FIX: Tombol refresh produk agar admin bisa memperbarui data tanpa scroll ke atas
        const SizedBox(height: 10),
        _RefreshStatsButton(onRefresh: onRefresh),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RefreshStatsButton — tombol refresh di bawah kartu statistik
// FIX: Ditambahkan agar admin dapat langsung memperbarui statistik & data produk
//      tanpa harus scroll ke atas mencari tombol refresh di AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _RefreshStatsButton extends StatelessWidget {
  final VoidCallback onRefresh;

  const _RefreshStatsButton({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text(
          "Perbarui Statistik & Produk",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2E9900),
          side: const BorderSide(color: Color(0xFF2E9900), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: const Color(0xFF2E9900).withValues(alpha: 0.04),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatCardWide
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
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
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
                color: accentColor.withValues(alpha: 0.08),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: accentColor.withValues(alpha: 0.4)),
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
                  color: Colors.white.withValues(alpha: 0.5),
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
// _StatCardSquare
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
            color: accentColor.withValues(alpha: 0.08),
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
              color: accentColor.withValues(alpha: 0.12),
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
// _StatCardHorizontal
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
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
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
                  color: accentColor.withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
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
                  color: accentColor.withValues(alpha: 0.10),
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
// _StatsSkeleton
// ─────────────────────────────────────────────────────────────────────────────

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E1A).withValues(alpha: 0.08),
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
        Row(
          children: [
            Expanded(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E9900).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E9900).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2E9900).withValues(alpha: 0.08),
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

  // FIX: Tentukan ikon & pesan berdasarkan jenis error
  IconData get _icon {
    final m = message.toLowerCase();
    if (m.contains('json') || m.contains('valid')) return Icons.data_object_rounded;
    if (m.contains('timeout') || m.contains('timed out')) return Icons.timer_off_rounded;
    if (m.contains('http') || m.contains('server')) return Icons.dns_rounded;
    return Icons.wifi_off_rounded;
  }

  String get _hint {
    final m = message.toLowerCase();
    if (m.contains('json') || m.contains('valid')) return 'Response server tidak valid — cek log PHP';
    if (m.contains('timeout') || m.contains('timed out')) return 'Server lambat merespons — coba lagi';
    if (m.contains('http 5')) return 'Error di sisi server (5xx) — cek dashboard_stats.php';
    if (m.contains('http 4')) return 'File PHP tidak ditemukan (4xx) — cek path URL';
    if (m.contains('connection') || m.contains('koneksi')) return 'Tidak dapat terhubung ke server';
    return 'Periksa koneksi & pastikan server aktif';
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Tampilkan pesan error asli (bukan hanya ikon wifi) agar mudah debugging
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD32F2F).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: const Color(0xFFD32F2F), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gagal memuat statistik",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD32F2F),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hint,
                      style: TextStyle(
                        color: const Color(0xFFD32F2F).withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E9900),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Coba Lagi",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          // FIX: Tampilkan detail error mentah agar admin bisa mendiagnosa masalah
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message.replaceFirst('Exception: ', ''),
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
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
              border: Border.all(color: data.accent.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: data.accent.withValues(alpha: 0.08),
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
                      colors: [data.accent.withValues(alpha: 0.85), data.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: data.accent.withValues(alpha: 0.3),
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
                    color: data.accent.withValues(alpha: 0.10),
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
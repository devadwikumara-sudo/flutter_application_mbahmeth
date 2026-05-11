import 'package:flutter/material.dart';
import 'history_screen.dart';
// Arahkan ke file yang memiliki form lengkap
import '../profile/view/edit_profile_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Warna tema ──────────────────────────────────────────────
  static const Color _green = Color(0xFF2E9900);
  static const Color _greenDark = Color(0xFF1D6600);
  static const Color _greenLight = Color(0xFFC9F6C5);
  static const Color _greenMid = Color(0xFF57C200);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HEADER GRADIENT ───────────────────────────────
            _buildHeader(context),

            // ── STATISTIK ─────────────────────────────────────
            _buildStatsRow(),

            const SizedBox(height: 24),

            // ── SECTION AKUN ──────────────────────────────────
            _buildSectionLabel('Akun Saya'),
            _buildMenuCard([
              _MenuItem(
                icon: Icons.history_rounded,
                label: 'Riwayat Pesanan',
                subtitle: 'Lihat semua pesanan Anda',
                badge: '3',
                onTap: () => Navigator.push(
                  context,
                  _slideRoute(const HistoryScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Pesanan Aktif',
                subtitle: 'Pantau pesanan berjalan',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.favorite_border_rounded,
                label: 'Wishlist',
                subtitle: 'Produk yang Anda simpan',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 16),

            // ── SECTION PENGATURAN ────────────────────────────
            _buildSectionLabel('Pengaturan'),
            _buildMenuCard([
              _MenuItem(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profil',
                subtitle: 'Ubah nama, foto, & info',
                onTap: () => Navigator.push(
                  context,
                  _slideRoute(const EditProfileScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.lock_outline_rounded,
                label: 'Keamanan',
                subtitle: 'Password & verifikasi',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.notifications_none_rounded,
                label: 'Notifikasi',
                subtitle: 'Atur preferensi notifikasi',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Bantuan & FAQ',
                subtitle: 'Pusat bantuan pelanggan',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 16),

            // ── TOMBOL KELUAR ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── VERSI APLIKASI ────────────────────────────────
            Text(
              'Toko Mbahmeth v1.0.0',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, bottom: 32, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_greenDark, _green, _greenMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          // Avatar + edit button
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.35), width: 3),
                ),
              ),
              CircleAvatar(
                radius: 58,
                backgroundColor: _greenLight,
                backgroundImage: const NetworkImage(
                  'https://cdn3d.iconscout.com/3d/premium/thumb/young-businessman-6228303-5121303.png',
                ),
              ),
              Positioned(
                bottom: 2,
                right: 62,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    _slideRoute(const EditProfileScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: _green,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Nama disesuaikan menjadi Pria Solo
          const Text(
            'Pria Solo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),

          // Email disesuaikan menjadi Bahlil@gmail.com
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 5),
              const Text(
                'Bahlil@gmail.com',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Badge member
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  'Member Aktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS ROW (Bagian kode lainnya tetap sama) ─────────────────
  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, -22, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(value: '12', label: 'Pesanan', icon: Icons.receipt_long_rounded),
          _buildDivider(),
          _StatItem(value: '3', label: 'Aktif', icon: Icons.local_shipping_outlined),
          _buildDivider(),
          _StatItem(value: '9', label: 'Selesai', icon: Icons.check_circle_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2B1D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuTile(item),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 20,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: _green, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1D2B1D),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
            if (item.badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Keluar?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context, rootNavigator: true)
                  .popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.badge,
    required this.onTap,
  });
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E9900), size: 22),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2B1D),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_mbahmeth/screens/customer_login.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const Color _green = Color(0xFF2E9900);
  static const Color _greenDark = Color(0xFF1F6B00);
  static const Color _greenLight = Color(0xFFE8F5E2);
  static const Color _bgColor = Color(0xFFF4FAF2);

  String _nama = 'Pengguna';
  String _email = '-';
  String? _fotoPath;

  // ── FIX Bug 2: Ganti nilai hard-coded dengan variabel dinamis ──
  int _totalPesanan = 0;
  int _totalSelesai = 0;
  int _totalDiproses = 0;
  bool _loadingStats = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _animCtrl.forward();
  }

  // ── Refresh stats saat app kembali ke foreground ──
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _nama = prefs.getString('nama') ??
          prefs.getString('name') ??
          prefs.getString('nama_lengkap') ??
          'Pengguna';
      _email = prefs.getString('email') ?? '-';
      _fotoPath = prefs.getString('foto_profil_path');
    });

    // ── FIX Bug 2: Ambil statistik dari API, bukan hard-code ──
    final userId = prefs.getInt('id_user') ?? 0;
    if (userId > 0) {
      await _loadStats(userId);
    } else {
      // User belum login, reset statistik
      if (mounted) {
        setState(() {
          _totalPesanan = 0;
          _totalSelesai = 0;
          _totalDiproses = 0;
        });
      }
    }
  }

  Future<void> _loadStats(int userId) async {
    if (!mounted) return;
    setState(() => _loadingStats = true);

    try {
      final orders = await ApiService().getOrdersByUser(userId);
      if (!mounted) return;

      // Hitung statistik:
      // - 'checkout' = pesanan sudah selesai/dikonfirmasi
      // - 'keranjang' = masih di keranjang (diproses / belum checkout)
      // Catatan: getOrdersByUser mengembalikan semua order termasuk 'keranjang'.
      // Kita tampilkan 'keranjang' sebagai "Diproses" di profil saja (bukan di history).
      final selesai =
          orders.where((o) => o['status']?.toString() == 'checkout').length;
      final diproses =
          orders.where((o) => o['status']?.toString() == 'keranjang').length;

      setState(() {
        _totalSelesai = selesai;
        _totalDiproses = diproses;
        _totalPesanan = selesai + diproses;
        _loadingStats = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _pickFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 400,
    );
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('foto_profil_path', picked.path);
      if (mounted) setState(() => _fotoPath = picked.path);
    }
  }

  Future<void> _logout(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Keluar Akun',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_user');
    await prefs.remove('nama');
    await prefs.remove('email');
    await prefs.remove('nama_lengkap');
    // ── FIX: Reset statistik saat logout ──
    if (mounted) {
      setState(() {
        _totalPesanan = 0;
        _totalSelesai = 0;
        _totalDiproses = 0;
        _nama = 'Pengguna';
        _email = '-';
        _fotoPath = null;
      });
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: CustomScrollView(
          slivers: [
            // ── SliverAppBar ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: _green,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_greenDark, _green, Color(0xFF5CC400)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor:
                                    Colors.white.withOpacity(0.2),
                                backgroundImage: _fotoPath != null
                                    ? FileImage(File(_fotoPath!))
                                    : null,
                                child: _fotoPath == null
                                    ? Text(
                                        _nama.isNotEmpty
                                            ? _nama[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          fontSize: 42,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickFoto,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                      )
                                    ],
                                  ),
                                  child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: _green,
                                      size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _nama,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Body Content ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    _buildStatsRow(),
                    const SizedBox(height: 24),

                    // Menu Akun
                    _buildSectionLabel('Akun Saya'),
                    const SizedBox(height: 10),
                    _buildMenuCard([
                      _MenuData(
                        icon: Icons.history_rounded,
                        label: 'Riwayat Pesanan',
                        subtitle: 'Lihat semua pesanan kamu',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HistoryScreen()),
                          );
                          // Refresh statistik setelah kembali dari history
                          _loadUserData();
                        },
                      ),
                      _MenuData(
                        icon: Icons.edit_rounded,
                        label: 'Ubah Nama',
                        subtitle: 'Perbarui nama tampilan',
                        onTap: () => _showEditDialog(),
                      ),
                      _MenuData(
                        icon: Icons.camera_alt_rounded,
                        label: 'Ganti Foto Profil',
                        subtitle: 'Upload dari galeri',
                        onTap: _pickFoto,
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Tombol Logout
                    GestureDetector(
                      onTap: () => _logout(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.red.shade100, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: Colors.red.shade400, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Keluar Akun',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FIX Bug 2: _buildStatsRow sekarang pakai data dari API ──
  Widget _buildStatsRow() {
    if (_loadingStats) {
      return Container(
        height: 90,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: _green,
          strokeWidth: 2,
        ),
      );
    }

    return Row(
      children: [
        _buildStatItem(
            'Pesanan', '$_totalPesanan', Icons.receipt_long_rounded),
        const SizedBox(width: 12),
        _buildStatItem(
            'Selesai', '$_totalSelesai', Icons.check_circle_rounded),
        const SizedBox(width: 12),
        _buildStatItem(
            'Diproses', '$_totalDiproses', Icons.timelapse_rounded),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: _green, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A2E1A),
              ),
            ),
            Text(
              label,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A2E1A),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _greenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: _green, size: 20),
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
                                color: Color(0xFF1A2E1A),
                              ),
                            ),
                            if (item.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle!,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.grey.shade300, size: 22),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade100,
                    indent: 74),
            ],
          );
        }),
      ),
    );
  }

  void _showEditDialog() {
    final ctrl = TextEditingController(text: _nama);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Nama',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Masukkan nama baru',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('nama', ctrl.text);
              setState(() => _nama = ctrl.text);
              if (mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  const _MenuData(
      {required this.icon,
      required this.label,
      this.subtitle,
      required this.onTap});
}
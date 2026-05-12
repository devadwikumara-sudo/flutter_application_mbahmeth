import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_mbahmeth/screens/customer_login.dart'; 
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _green = Color(0xFF2E9900);
  static const Color _greenLight = Color(0xFFC9F6C5);

  String _nama = 'Pengguna';
  String _email = '-';
  String? _fotoPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _nama = prefs.getString('nama') ??
            prefs.getString('name') ??
            prefs.getString('nama_lengkap') ??
            'Pengguna';
        _email = prefs.getString('email') ?? '-';
        _fotoPath = prefs.getString('foto_profil_path');
      });
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_user');
    await prefs.remove('nama');
    await prefs.remove('email');
    await prefs.remove('nama_lengkap');

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()), 
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar Hijau sesuai permintaan
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        centerTitle: true,
        // Tombol Back di AppBar Hijau
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // PERBAIKAN TOMBOL BACK:
            // Jika ada halaman sebelumnya, dia akan kembali.
            // Jika tidak ada (mencegah black screen), dia akan menutup layar ini.
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Jika kamu ingin memaksa kembali ke home jika pop gagal:
              // Navigator.of(context).pushReplacementNamed('/home'); 
              debugPrint("Navigation stack kosong");
            }
          },
        ),
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Menghilangkan tombol keranjang (actions dikosongkan)
        actions: const [], 
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // ── AVATAR ────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: _greenLight,
                    backgroundImage: _fotoPath != null
                        ? FileImage(File(_fotoPath!))
                        : null,
                    child: _fotoPath == null
                        ? Text(
                            _nama.isNotEmpty ? _nama[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 40, color: _green, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickFoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            Text(_nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_email, style: const TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 30),

            _buildMenu(Icons.history, 'Riwayat Pesanan', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            }),
            _buildMenu(Icons.edit, 'Ubah Nama', () => _showEditDialog()),
            
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar Akun'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: _green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showEditDialog() {
    final ctrl = TextEditingController(text: _nama);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Nama'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('nama', ctrl.text);
              setState(() => _nama = ctrl.text);
              if (mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
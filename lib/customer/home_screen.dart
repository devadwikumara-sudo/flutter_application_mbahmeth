import 'package:flutter/material.dart';
// Import file tetangga di satu folder 'customer'
import 'cart_screen.dart'; 
import 'history_screen.dart'; 
import 'notification_screen.dart'; 
import 'home_content.dart'; 
// Import file profile tetap keluar satu folder karena beda folder
import '../profile/view/edit_profile_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = ['Beranda', 'Keranjang', 'Notifikasi', 'Profil'];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: 
        return const HomeContent(); 
      case 1: 
        // Pastikan di file cart_screen.dart nama class-nya adalah CartContent
        return const CartContent(); 
      case 2: 
        return const NotificationScreen(); 
      case 3: 
        return const _ProfileBody();
      default: 
        return const HomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0
          ? null 
          : AppBar(
              backgroundColor: const Color(0xFF2E9900),
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(_titles[_selectedIndex],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2E9900),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// --- TAB PROFIL ---
class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFFC9F6C5),
                  backgroundImage: NetworkImage('https://cdn3d.iconscout.com/3d/premium/thumb/young-businessman-6228303-5121303.png'),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF577E3D),
                      child: Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text('Ammar Tubagus', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('ammar@student.polije.ac.id', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),

          _ProfileMenuItem(
            icon: Icons.history,
            title: 'Riwayat Pesanan',
            subtitle: 'Lihat pesanan Anda',
            color: const Color(0xFFC9F6C5),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          _ProfileMenuItem(
            icon: Icons.settings,
            title: 'Pengaturan',
            subtitle: 'Kelola profil',
            color: const Color(0xFFC9F6C5),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          _ProfileMenuItem(
            icon: Icons.logout,
            title: 'Keluar dari Akun',
            subtitle: '',
            color: const Color(0xFFFEE2E2),
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET HELPER ---
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _ProfileMenuItem({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.onTap,
    this.iconColor = const Color(0xFF2E9900),
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
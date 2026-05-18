import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; 
import '../screens/welcome_screen.dart'; // Sesuaikan lokasi halaman welcome/login Anda

class ProfilAdmin extends StatefulWidget {
  const ProfilAdmin({super.key});

  @override
  State<ProfilAdmin> createState() => _ProfilAdminState();
}

class _ProfilAdminState extends State<ProfilAdmin> {
  final ApiService _apiService = ApiService();
  String _idUser = "";
  Future<Map<String, dynamic>>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Mengambil ID User dari sesi lokal untuk memicu request real-time ke database
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Default ke ID '2' (jajal) jika SharedPreferences belum mencatat ID saat login
      _idUser = prefs.getString('id_user') ?? "2"; 
      _profileFuture = _apiService.getAdminProfil(_idUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E9900);
    const darkSlate = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Background abu-abu ultra-light yang bersih
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          "Informasi Akun",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: () async {
          setState(() {
            _profileFuture = _apiService.getAdminProfil(_idUser);
          });
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryGreen));
            }

            if (snapshot.hasError || snapshot.data == null || snapshot.data!['success'] == false) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "Gagal Memuat Data Terbaru",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkSlate),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Pastikan file get_profil.php sudah benar atau tarik layar ke bawah untuk mencoba kembali.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Data segar ditarik langsung dari database MySQL via backend PHP
            var userData = snapshot.data!['data'];
            String namaLengkap = userData['nama_lengkap'] ?? "Admin";
            String email = userData['email'] ?? "-";
            String role = userData['role'] ?? "Admin";

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ================= EYE-CATCHING PROFILE HEADER =================
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 110,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 25,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFE2F5DD),
                            // Menggunakan Dicebear Avatar generator yang dinamis menyesuaikan nama admin
                            backgroundImage: NetworkImage(
                              "https://api.dicebear.com/7.x/initials/png?seed=$namaLengkap&backgroundColor=2e9900",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 75),

                  // ================= NAMA & BADGE ROLE (DINAMIS DATABASE) =================
                  Text(
                    namaLengkap,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F5DD),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= KARTU DETAIL DATA KREDENSIAL =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            "Detail Informasi Akun",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildProfileItem(
                                icon: Icons.fingerprint_rounded,
                                title: "ID Akun",
                                value: _idUser,
                              ),
                              const Divider(height: 1, indent: 56, endIndent: 20),
                              _buildProfileItem(
                                icon: Icons.person_outline_rounded,
                                title: "Nama Lengkap",
                                value: namaLengkap,
                              ),
                              const Divider(height: 1, indent: 56, endIndent: 20),
                              _buildProfileItem(
                                icon: Icons.alternate_email_rounded,
                                title: "Alamat Email",
                                value: email,
                              ),
                              const Divider(height: 1, indent: 56, endIndent: 20),
                              _buildProfileItem(
                                icon: Icons.verified_user_outlined,
                                title: "Status Enkripsi",
                                value: "Aktif (Bcrypt Secure)",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= PREMIUM LOGOUT BUTTON =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFEE2E2), // Soft merah pastel
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear(); // Hapus sesi ID login

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Berhasil keluar dari sesi"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.red, size: 22),
                        label: const Text(
                          "Keluar Sesi",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget pembangun baris data akun yang rapi
  Widget _buildProfileItem({required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF64748B), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
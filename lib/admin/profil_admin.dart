import 'package:flutter/material.dart';

class ProfilAdmin extends StatefulWidget {
  const ProfilAdmin({super.key});

  @override
  State<ProfilAdmin> createState() => _ProfilAdminState();
}

class _ProfilAdminState extends State<ProfilAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(),
              _profileSection(),
              _settingsSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      color: const Color(0xFF2E9900),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 12),
          Text(
            "Profil Admin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  // ================= PROFILE =================
  Widget _profileSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/22766fdd-1daf-4768-af1e-e2eb2225ae87",
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(blurRadius: 4, color: Colors.black26)
                    ],
                  ),
                  child: const Icon(Icons.edit, size: 16),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Admin Mbah Met",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Super Administrator",
            style: TextStyle(color: Color(0xFF577E3D)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.email, size: 16, color: Colors.grey),
              SizedBox(width: 6),
              Text(
                "admin@tani12.com",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================= SETTINGS =================
  Widget _settingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pengaturan Akun",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Card Pengaturan
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F6),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(blurRadius: 2, color: Colors.black12)
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Kelola Akun"),
              subtitle: const Text("Informasi pribadi dan profil"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout, color: Color(0xFFDC2626)),
                  SizedBox(width: 10),
                  Text(
                    "Keluar Sesi",
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
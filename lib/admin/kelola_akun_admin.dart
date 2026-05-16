import 'package:flutter/material.dart';

class KelolaAkunAdmin extends StatefulWidget {
  const KelolaAkunAdmin({super.key});

  @override
  State<KelolaAkunAdmin> createState() => _KelolaAkunAdminState();
}

class _KelolaAkunAdminState extends State<KelolaAkunAdmin> {
  final TextEditingController namaController =
      TextEditingController(text: "Budi Darmawan");

  final TextEditingController emailController =
      TextEditingController(text: "admin@tani12.com");

  final TextEditingController passwordController =
      TextEditingController(text: "budi123");

  final TextEditingController phoneController =
      TextEditingController(text: "+62 812 3456 7890");

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF329311);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // PROFILE
            Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFD1E9C9),

                        backgroundImage: const NetworkImage(
                          "https://i.pravatar.cc/300",
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,

                        child: Container(
                          padding: const EdgeInsets.all(6),

                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Admin Mbah Met",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Super Administrator",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FORM
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  _buildTextField(
                    label: "Nama Lengkap",
                    controller: namaController,
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 18),

                  _buildTextField(
                    label: "Alamat Email",
                    controller: emailController,
                    icon: Icons.email,
                  ),

                  const SizedBox(height: 18),

                  _buildTextField(
                    label: "Kata Sandi",
                    controller: passwordController,
                    icon: Icons.lock,
                    obscureText: true,
                  ),

                  const SizedBox(height: 18),

                  _buildTextField(
                    label: "Nomor Telepon",
                    controller: phoneController,
                    icon: Icons.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // BUTTON SIMPAN
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Perubahan berhasil disimpan",
                      ),
                    ),
                  );
                },

                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BUTTON LOGOUT
            SizedBox(
              width: double.infinity,
              height: 55,

              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.redAccent,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Logout berhasil"),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                ),

                label: const Text(
                  "Keluar Sesi",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: obscureText,

          decoration: InputDecoration(
            prefixIcon: Icon(icon),

            filled: true,
            fillColor: const Color(0xFFF8F9FA),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF329311),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
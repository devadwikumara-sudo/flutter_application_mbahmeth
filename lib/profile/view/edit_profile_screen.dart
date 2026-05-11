import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Pria Solo');
    _emailController = TextEditingController(text: 'Bahlil@gmail.com');
    _phoneController = TextEditingController(text: '08123456789');
    _addressController = TextEditingController(text: 'Jl. Merdeka No. 123, Solo');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E9900),
        elevation: 0,
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Foto Profil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFC9F6C5),
                      backgroundImage: const NetworkImage('https://placehold.co/200x200'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          // Add image picker logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur upload foto akan segera hadir')),
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF577E3D),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Nama
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Telepon
              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Alamat
              _buildTextField(
                controller: _addressController,
                label: 'Alamat',
                icon: Icons.location_on,
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Add save logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil berhasil diperbarui')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9900),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF2E9900)),
        prefixIcon: Icon(icon, color: const Color(0xFF2E9900)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E9900), width: 2),
        ),
      ),
    );
  }
}

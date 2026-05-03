import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/success_screen.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/custom_text_field.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // 1. Tambahkan Controller untuk menangkap input teks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 2. Fungsi untuk mengirim data ke Database via PHP
  void _handleRegister() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validasi dasar di sisi aplikasi
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Semua kolom harus diisi", Colors.red);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Konfirmasi kata sandi tidak cocok", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sesuaikan URL dengan IP Laptop Anda (cek ipconfig)[cite: 1]
      final response = await http.post(
        Uri.parse("http://192.168.0.51/toko_mbahmeth/api/register.php"),
        body: {
          "nama_lengkap": name,
          "email": email,
          "password": password,
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // Jika berhasil simpan ke database
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              title: 'Akun Berhasil Dibuat',
              subtitle: 'Selamat Bergabung di\nTOKO MBAHMETH',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );
      } else {
        // Tampilkan pesan error dari PHP (misal: Email sudah ada)
        _showSnackBar(data['message'], Colors.red);
      }
    } catch (e) {
      _showSnackBar("Gagal terhubung ke server. Pastikan Apache menyala.", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            
            const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _nameController,
              hintText: 'Masukkan Nama Lengkap',
              prefixIcon: Icons.person_outline,
            ),
            
            const SizedBox(height: 20),

            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              hintText: 'Masukkan Email',
              prefixIcon: Icons.email_outlined,
            ),
            
            const SizedBox(height: 20),
            
            const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              hintText: 'Masukkan Kata Sandi',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            
            const SizedBox(height: 20),

            const Text('Konfirmasi Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              hintText: 'Ulangi Kata Sandi',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            
            const SizedBox(height: 32),
            
            _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : PrimaryButton(
                  text: 'DAFTAR',
                  onPressed: _handleRegister,
                ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sudah punya akun? ', style: TextStyle(color: AppColors.textDark)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
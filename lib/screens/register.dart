import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/success_screen.dart';
import 'package:flutter_application_mbahmeth/screens/failure_screen.dart';
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
  final TextEditingController _nameController = TextEditingController();

  void _handleRegister() {
    // Mock logic: if name is empty, fail, else success
    if (_nameController.text.trim().isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FailureScreen(
            title: 'Daftar Gagal',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: 'Akun Berhasil Dibuat',
            subtitle: 'Selamat Bergabung di\nTOKO MBAHMET',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
            // Logo
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Menggunakan gambar logo langsung
                width: 200, // Ukuran disesuaikan agar pas di layar
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            
            // Nama Lengkap
            const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _nameController,
              hintText: 'Masukkan Nama Pengguna',
              prefixIcon: Icons.person_outline,
            ),
            
            const SizedBox(height: 20),

            // No hp atau Email
            const Text('No hp atau Email', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'Masukkan email atau No HP',
              prefixIcon: Icons.email_outlined,
            ),
            
            const SizedBox(height: 20),
            
            // Password Field
            const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
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

            // Konfirmasi Password Field
            const Text('Konfirmasi Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              obscureText: _obscureConfirmPassword,
              hintText: 'Masukkan Kata Sandi',
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
            
            // Register Button
            PrimaryButton(
              text: 'DAFTAR',
              onPressed: _handleRegister,
            ),
            
            const SizedBox(height: 24),
            
            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sudah punya akun? ', style: TextStyle(color: AppColors.textDark)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Go back to login screen
                  },
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/customer_login.dart';
import 'package:flutter_application_mbahmeth/widgets/custom_text_field.dart';
import 'package:flutter_application_mbahmeth/widgets/primary_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _obscurePassword = true;

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
            // Logo Placeholder
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Sesuaikan path asset Anda
                    width: 180, // Ukuran disesuaikan agar proporsional
                    height: 180,
                    fit: BoxFit.contain,
                  ),
      
                  const SizedBox(height: 24),

                  // 2. Teks Akses Admin (Tetap dipertahankan)
                  const Text(
                    'Akses Admin',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36), 
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 3. Teks Selamat Datang Admin (Tetap dipertahankan)
                  const Text(
                    'Selamat Datang Admin',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Tab Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate back to user login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: AppColors.textDark,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Masuk Pengguna',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {}, // Already on admin tab
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.admin_panel_settings_outlined,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Masuk Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Email Field
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'Masukkan email atau Nama Pengguna',
              prefixIcon: Icons.email_outlined,
            ),
            
            const SizedBox(height: 20),
            
            // Password Field
            const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              obscureText: _obscurePassword,
              hintText: 'Masukkan Password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Login Button
            PrimaryButton(
              text: 'Masuk',
              onPressed: () {
                // TODO: Implement Admin Login
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

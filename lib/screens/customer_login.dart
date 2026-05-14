import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/register.dart';
import 'package:flutter_application_mbahmeth/screens/admin_login.dart';
import 'package:flutter_application_mbahmeth/screens/failure_screen.dart';
import 'package:flutter_application_mbahmeth/screens/success_screen.dart';
import 'package:flutter_application_mbahmeth/screens/forgot_password.dart';
import 'package:flutter_application_mbahmeth/customer/customer.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/custom_text_field.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';
import 'package:flutter_application_mbahmeth/screens/welcome_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email/Username dan Password harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await loginUser(email, password);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.customerUrl}/login.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"email": email, "password": password},
      ).timeout(const Duration(seconds: 10));

      if (response.body.isEmpty) throw Exception("Server memberikan respon kosong.");
      final data = json.decode(response.body);

      if (data['status'] == "success") {
        final user = data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_user', (user['id_user'] as num).toInt());
        await prefs.setString('nama', user['nama'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        await prefs.setString('role', user['role'] ?? '');

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              title: 'Masuk Berhasil',
              subtitle: 'Selamat Datang, ${user['nama']}',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FailureScreen(
              title: data['message'] ?? 'Masuk Gagal',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: Stack(
        children: [
          // Background Dekoratif
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _emailController.clear();
                  _passwordController.clear();
                });
                await Future.delayed(const Duration(seconds: 1));
              },
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Tombol Kembali
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/x1.png',
                        width: 300,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const Text(
                        "Selamat Datang Kembali!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Masuk untuk melanjutkan belanja Anda",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      
                      const SizedBox(height: 30),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Tab Toggle
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F5F7),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryGreen.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text('Pengguna',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque, 
                                      onTap: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent, 
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Admin',
                                            style: TextStyle(
                                              color: AppColors.textDark, 
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            const Text('Email / Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Masukkan kredensial Anda',
                              prefixIcon: Icons.alternate_email_rounded,
                            ),

                            const SizedBox(height: 20),
                            const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              hintText: 'Masukkan Kata Sandi',
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                                child: const Text('Lupa Kata Sandi?',
                                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                              ),
                            ),

                            const SizedBox(height: 10),

                            _isLoading
                                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                                : PrimaryButton(
                                    text: 'Masuk Sekarang',
                                    onPressed: _handleLogin,
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      
                      // Link ke Pendaftaran
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun? ', style: TextStyle(color: AppColors.textDark)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                            child: const Text('Daftar Akun',
                                style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
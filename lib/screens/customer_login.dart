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
import 'package:flutter_application_mbahmeth/screens/welcome_screen.dart'; // ← PASTIKAN IMPORT INI ADA

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
        const SnackBar(content: Text('Email dan Password harus diisi')),
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

      if (response.body.isEmpty) {
        throw Exception("Server memberikan respon kosong.");
      }

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
                  MaterialPageRoute(
                      builder: (context) => const CustomerHomeScreen()),
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
      debugPrint("--- DETAIL ERROR LOGIN ---");
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // PERBAIKAN: Cek apakah bisa kembali, jika tidak bisa arahkan ke Welcome
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),

            // Tab Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Masuk Pengguna',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AdminLoginScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.admin_panel_settings_outlined,
                                color: AppColors.textDark),
                            SizedBox(width: 8),
                            Text('Masuk Admin',
                                style: TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text('Email',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              hintText: 'Masukkan email',
              prefixIcon: Icons.email_outlined,
            ),

            const SizedBox(height: 20),
            const Text('Kata Sandi',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              hintText: 'Masukkan Kata Sandi',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen())),
                child: const Text('Lupa Kata Sandi?',
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 16),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen))
                : PrimaryButton(
                    text: 'Masuk',
                    onPressed: _handleLogin,
                  ),

            const SizedBox(height: 24),
            const Center(
                child: Text('atau',
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500))),
            const SizedBox(height: 24),

            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata,
                    size: 36, color: AppColors.primaryGreen),
                label: const Text('Google',
                    style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum punya akun? ',
                    style: TextStyle(color: AppColors.textDark)),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen())),
                  child: const Text('Daftar',
                      style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold)),
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
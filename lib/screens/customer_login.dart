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
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

 // Ganti fungsi lama di customer_login.dart dengan ini
void _handleLogin() async {
  String email = _emailController.text;
  String password = _passwordController.text; // Pastikan controller password sudah ada

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email dan Password harus diisi')),
    );
    return;
  }

  // Panggil fungsi API login
  await loginUser(email, password);
}
Future<void> loginUser(String email, String password) async {
  try {
    final response = await http.post(
      // Ganti IP_LAPTOP dengan IP asli dari cmd (ipconfig)
      Uri.parse("http://192.168.0.51/toko_mbahmeth/api/login.php"),
      body: {"email": email, "password": password},
    );

    var data = json.decode(response.body);

    if (data['status'] == "success") {
      if (!mounted) return;
      // Jika berhasil, arahkan ke SuccessScreen (Source 5)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: 'Masuk Berhasil',
            subtitle: 'Selamat Datang, ${data['user']['nama']}',
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
      // Jika gagal (email/password salah), arahkan ke FailureScreen (Source 5)
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
    debugPrint("Error: $e");
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal terhubung ke server Laragon')),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Logo Placeholder
            const SizedBox(height: 20),
            // === BAGIAN YANG DIRUBAH ===
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Menggunakan gambar logo langsung
                width: 200, // Ukuran disesuaikan agar pas di layar
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            // Teks "TOKO MBAHMETH" dihapus karena sudah ada di dalam gambar logo
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
                    child: GestureDetector(
                      onTap: () {}, // Already on user tab
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
                              Icons.person_outline,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Masuk Pengguna',
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
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to Admin Login Screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
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
                              Icons.admin_panel_settings_outlined,
                              color: AppColors.textDark,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Masuk Admin',
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
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Email Field
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              hintText: 'Masukkan email atau Nama Pengguna (ketik "user")',
              prefixIcon: Icons.email_outlined,
            ),
            
            const SizedBox(height: 20),
            
            // Password Field
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
            
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  'Lupa Kata Sandi?',
                  style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Login Button
            PrimaryButton(
              text: 'Masuk',
              onPressed: _handleLogin,
            ),
            
            const SizedBox(height: 24),
            const Center(child: Text('atau', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500))),
            const SizedBox(height: 24),
            
            // Google Login Button
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Google login action
                },
                icon: const Icon(Icons.g_mobiledata, size: 36, color: AppColors.primaryGreen), // Placeholder for Google Icon
                label: const Text(
                  'Google',
                  style: TextStyle(color: AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum punya akun? ', style: TextStyle(color: AppColors.textDark)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Daftar',
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

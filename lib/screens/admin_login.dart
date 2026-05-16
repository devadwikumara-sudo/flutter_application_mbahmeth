import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/customer_login.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/custom_text_field.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/primary_button.dart';
import 'package:flutter_application_mbahmeth/admin/dashboard.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _handleAdminLogin() async {
    String identifier = _identifierController.text.trim();
    String password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showSnackBar("Email/Username dan Password tidak boleh kosong");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.login(identifier, password);

      if (response['status'] == 'success') {
        if (response['user']['role'] == 'admin') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          _showSnackBar("Akses Ditolak: Anda bukan Admin");
        }
      } else {
        _showSnackBar(response['message'] ?? "Login Gagal");
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan koneksi");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9), // Background lembut sesuai Customer Login
      body: Stack(
        children: [
          // Elemen Dekoratif Background (Lingkaran halus)
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
                  _identifierController.clear();
                  _passwordController.clear();
                });
                await Future.delayed(const Duration(seconds: 1));
              },
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Back Button kustom
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Logo & Greeting (Sesuai gaya Customer)
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/images/x1.png',
                      width: 300,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      "Akses Admin",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Silakan masuk untuk mengelola sistem",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 30),

                    // Kontainer Form Utama (Card)
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
                                  child: GestureDetector(
                                  // Menambahkan behavior agar area transparan bisa mendeteksi sentuhan
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      );
                                    },
                                    child: Container(
                                    // Padding vertikal untuk memperluas area tekan ke atas dan bawah
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent, // Tetap transparan agar mengikuti background toggle
                                      ),
                                      child: const Center(
                                      child: Text(
                                        'Pengguna',
                                        style: TextStyle(
                                          color: AppColors.textDark,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                      child: Text('Admin',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Text('Email / Username', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _identifierController,
                            hintText: 'Masukkan kredensial',
                            prefixIcon: Icons.admin_panel_settings_outlined,
                          ),

                          const SizedBox(height: 20),

                          const Text('Kata Sandi', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
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

                          const SizedBox(height: 32),

                          _isLoading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                              : PrimaryButton(
                                  text: 'Masuk Sekarang',
                                  onPressed: _handleAdminLogin,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
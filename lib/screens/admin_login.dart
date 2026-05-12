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

  // 1. Tambahkan Controller untuk mengambil input
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  // 2. Fungsi Login dengan Validasi Role Admin
  void _handleAdminLogin() async {
    String identifier = _identifierController.text.trim();
    String password = _passwordController.text.trim();
    debugPrint("Mencoba Login: $identifier | Password: $password");

    if (identifier.isEmpty || password.isEmpty) {
      _showSnackBar("Email/Username dan Password tidak boleh kosong");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Memanggil fungsi login dari ApiService
      final response = await _apiService.login(identifier, password);

      if (response['status'] == 'success') {
        // Cek apakah user yang login memiliki role 'admin'
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
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Akses Admin',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36), 
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline, color: AppColors.textDark),
                            SizedBox(width: 8),
                            Text('Masuk Pengguna', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                          Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Masuk Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text('Email / Username', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            // 3. Hubungkan TextField dengan Controller
            CustomTextField(
              controller: _identifierController,
              hintText: 'Masukkan email atau Nama Pengguna',
              prefixIcon: Icons.email_outlined,
            ),
            
            const SizedBox(height: 20),
            
            const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            // 3. Hubungkan TextField dengan Controller
            CustomTextField(
              controller: _passwordController,
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
            
            // 4. Update Button untuk menjalankan fungsi login
            _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
              : PrimaryButton(
                  text: 'Masuk',
                  onPressed: _handleAdminLogin,
                ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
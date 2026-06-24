import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/success_screen.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/custom_text_field.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/primary_button.dart';
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_mbahmeth/customer/customer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  static final _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

  void _handleRegister() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'Nama lengkap tidak boleh kosong');
      hasError = true;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Email tidak boleh kosong');
      hasError = true;
    } else if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Format email tidak valid');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Kata sandi tidak boleh kosong');
      hasError = true;
    } else if (password.length < 8) {
      setState(() => _passwordError = 'Kata sandi minimal 8 karakter');
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Konfirmasi kata sandi tidak boleh kosong');
      hasError = true;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Konfirmasi kata sandi tidak cocok');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.customerUrl}/register.php"),
        body: {
          "nama_lengkap": name,
          "email": email,
          "password": password,
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              title: 'Pendaftaran Berhasil',
              subtitle: data['message'] ?? 'Silakan masuk menggunakan akun baru Anda',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      } else {
        _showSnackBar(data['message'] ?? 'Pendaftaran gagal', Colors.red);
      }
    } catch (e) {
      _showSnackBar("Gagal terhubung ke server.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User canceled
      }

      final response = await http.post(
        Uri.parse("${AppConfig.customerUrl}/google_login.php"),
        body: {
          "google_id": googleUser.id,
          "email": googleUser.email,
          "nama_lengkap": googleUser.displayName ?? '',
          "foto_profil": googleUser.photoUrl ?? ''
        },
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      if (data['status'] == "success") {
        final user = data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_user', (user['id_user'] as num).toInt());
        await prefs.setString('nama', user['nama'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        await prefs.setString('role', user['role'] ?? '');
        await prefs.setString('foto_profil', user['foto_profil'] ?? '');

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        _showSnackBar(data['message'] ?? 'Pendaftaran Google Gagal', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal terhubung: ${e.toString()}', Colors.red);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
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
      backgroundColor: const Color(0xFFF8FAF9), // Background lembut
      body: Stack(
        children: [
          // Lingkaran Dekoratif (Sama dengan Login agar Konsisten)
          Positioned(
            top: -80,
            right: -50,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Custom Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  Center(
                    child: Image.asset(
                      'assets/images/x1.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "Buat Akun Baru",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Lengkapi data di bawah untuk mendaftar",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Form dalam Card agar lebih menonjol
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Nama lengkap Anda',
                            prefixIcon: Icons.person_outline_rounded,
                            errorText: _nameError,
                            enabled: !_isLoading,
                            autofillHints: const [AutofillHints.name],
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 20),
                          const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'nama@email.com',
                            prefixIcon: Icons.alternate_email_rounded,
                            errorText: _emailError,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 20),
                          const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            hintText: 'Minimal 8 karakter',
                            prefixIcon: Icons.lock_outline_rounded,
                            errorText: _passwordError,
                            enabled: !_isLoading,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: _isLoading ? null : () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Text('Konfirmasi Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            hintText: 'Ulangi kata sandi',
                            prefixIcon: Icons.lock_reset_rounded,
                            errorText: _confirmPasswordError,
                            enabled: !_isLoading,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleRegister(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: _isLoading ? null : () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),

                          const SizedBox(height: 30),

                           _isLoading 
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)) 
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  PrimaryButton(
                                    text: 'DAFTAR SEKARANG',
                                    onPressed: _handleRegister,
                                  ),
                                  const SizedBox(height: 15),
                                  OutlinedButton.icon(
                                    icon: Image.asset('assets/images/google_logo.png', height: 24, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, size: 30, color: Colors.red)),
                                    label: const Text('Daftar dengan Google', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                    onPressed: _handleGoogleRegister,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? ', style: TextStyle(color: AppColors.textDark)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Masuk Disini',
                          style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
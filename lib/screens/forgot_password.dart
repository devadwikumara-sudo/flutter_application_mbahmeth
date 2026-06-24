import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/success_screen.dart';

import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/custom_text_field.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/primary_button.dart';
import 'package:flutter_application_mbahmeth/core/config/app_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSendingOtp = false;
  bool _otpSent = false;

  String? _emailError;
  String? _otpError;
  String? _passwordError;
  String? _confirmPasswordError;

  static final _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

  void _sendOtp() async {
    setState(() => _emailError = null);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email tidak boleh kosong');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Format email tidak valid');
      return;
    }
    setState(() => _isSendingOtp = true);
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.customerUrl}/send_otp.php"),
        body: {"email": email},
      ).timeout(const Duration(seconds: 15));
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() => _otpSent = true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP telah dikirim ke email Anda'), backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal mengirim OTP'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal terhubung ke server'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
    if (mounted) setState(() => _isSendingOtp = false);
  }

  void _handleSubmit() async {
    setState(() {
      _otpError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPass = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    bool hasError = false;

    if (otp.isEmpty) {
      setState(() => _otpError = 'Kode OTP tidak boleh kosong');
      hasError = true;
    } else if (otp.length < 6) {
      setState(() => _otpError = 'Kode OTP harus 6 digit');
      hasError = true;
    }

    if (newPass.isEmpty) {
      setState(() => _passwordError = 'Kata sandi tidak boleh kosong');
      hasError = true;
    } else if (newPass.length < 8) {
      setState(() => _passwordError = 'Kata sandi minimal 8 karakter');
      hasError = true;
    }

    if (confirmPass.isEmpty) {
      setState(() => _confirmPasswordError = 'Konfirmasi kata sandi tidak boleh kosong');
      hasError = true;
    } else if (newPass != confirmPass) {
      setState(() => _confirmPasswordError = 'Konfirmasi kata sandi tidak cocok');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.customerUrl}/forgot_password.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "email": email,
          "otp": otp,
          "new_password": newPass,
        },
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              title: 'Kata Sandi Berhasil Diubah',
              subtitle: 'Silahkan masuk kembali menggunakan\nkata sandi baru Anda',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal mengubah kata sandi'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung ke server: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: Stack(
        children: [
          // Lingkaran Dekoratif (Konsisten dengan Login/Register)
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header Icon & Text
                  const Center(
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 80,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Lupa Kata Sandi?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Masukkan email dan kata sandi baru Anda\nuntuk memulihkan akun.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                  ),

                  const SizedBox(height: 40),

                  // Form Container (Card Style)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Konfirmasi Email',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'nama@email.com',
                          prefixIcon: Icons.email_outlined,
                          errorText: _emailError,
                          enabled: !_isSendingOtp && !_isLoading,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _sendOtp(),
                        ),
                        const SizedBox(height: 10),
                        _isSendingOtp
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                            : OutlinedButton(
                                onPressed: _isLoading ? null : _sendOtp,
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryGreen)),
                                child: Text(_otpSent ? 'Kirim Ulang OTP' : 'Kirim OTP ke Email', style: const TextStyle(color: AppColors.primaryGreen)),
                              ),

                        if (_otpSent) ...[
                          const SizedBox(height: 20),
                          const Text('Kode OTP', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _otpController,
                            hintText: 'Masukkan 6 digit OTP',
                            prefixIcon: Icons.mark_email_read_outlined,
                            errorText: _otpError,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                        const SizedBox(height: 20),

                        const Text('Kata Sandi Baru',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
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

                        const Text('Konfirmasi Kata Sandi',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          hintText: 'Ulangi kata sandi baru',
                          prefixIcon: Icons.lock_clock_outlined,
                          errorText: _confirmPasswordError,
                          enabled: !_isLoading,
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleSubmit(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: _isLoading ? null : () =>
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),

                        const SizedBox(height: 32),

                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: AppColors.primaryGreen))
                            : PrimaryButton(
                                text: 'SIMPAN PERUBAHAN',
                                onPressed: _handleSubmit,
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Back to Login
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Ingat kata sandi? ', style: TextStyle(color: Colors.grey)),
                        Text(
                          'Masuk Sekarang',
                          style: TextStyle(
                              color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
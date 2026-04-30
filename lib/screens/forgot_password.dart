import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/success_screen.dart';
import 'package:flutter_application_mbahmeth/screens/failure_screen.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/custom_text_field.dart';
import 'package:flutter_application_mbahmeth/widgets/widgetscustomer/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _handleSubmit() {
    // Mock logic: if email is empty, fail, else success
    if (_emailController.text.trim().isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FailureScreen(
            title: 'Sandi tidak tepat',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: 'Kata Sandi berhasil dirubah',
            subtitle: 'Selamat Bergabung Di\nMbahMeth',
            onPressed: () => Navigator.pop(context), // Should ideally go to login
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
            const Text(
              'Lupa Kata Sandi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Masukkan email Anda untuk menerima\ninstruksi reset kata sandi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 48),
            
            // Ubah kata sandi baru
            const Text(
              'Ubah kata sandi baru',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'masukan kata sandi',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              obscureText: _obscurePassword,
            ),

            
            const SizedBox(height: 24),
            
            // Konfirmasi kata sandi
            const Text(
              'Konfirmasi kata sandi',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'masukan kata sandi',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              obscureText: _obscureConfirmPassword,
            ),

            
            const SizedBox(height: 24),
            
            // Konfirmasi email
            const Text(
              'Konfirmasi email',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'nama@email.com',
              controller: _emailController,
            ),

            
            const SizedBox(height: 40),
            
            // Kirim Instruksi Button
            PrimaryButton(
              text: 'Kirim Instruksi ',
              onPressed: _handleSubmit,
              icon: const Icon(Icons.send_outlined, color: Colors.white, size: 20),
            ),
            
            const SizedBox(height: 48),
            
            // Kembali ke Halaman Login
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Kembali ke ',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                  Text(
                    'Halaman Login',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

}

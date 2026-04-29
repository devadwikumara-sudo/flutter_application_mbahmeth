import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/customer_login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // 1. Mengganti background warna lama dengan gambar sesuai desain
          image: const DecorationImage(
            image: AssetImage('assets/images/wellcome.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54, 
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                // 2. Menampilkan Logo langsung tanpa lingkaran hijau dan tanpa teks di bawahnya
                Image.asset(
                  'assets/images/logo.png',
                  width: 200, // Ukuran disesuaikan agar terlihat proporsional
                  height: 200,
                ),
                const Spacer(),
                // 3. Teks kembali ke Style asli Anda (Warna, Ukuran, dan Jarak tetap sama)
                const Text(
                  'Selamat Datang di\nToko Mbahmeth',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'kemudahan memesan obat-obatan sawah langsung tanpa antrei',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70, // Kembali ke warna asli Anda
                  ),
                ),
                const SizedBox(height: 48),
                // 4. Tombol kembali ke Style asli Anda
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'MULAI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
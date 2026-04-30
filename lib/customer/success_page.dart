import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- Fake iPhone Status Bar ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 12), // Padding atas untuk simulasi notch
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                ),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black),
                    SizedBox(width: 4),
                    Icon(Icons.wifi, size: 16, color: Colors.black),
                    SizedBox(width: 4),
                    Icon(Icons.battery_full, size: 18, color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png', // Silakan masukkan gambar logo Toko MbahMeth dengan nama logo.png
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.store_mall_directory,
                      size: 100,
                      color: Color(0xFF339F16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Judul Selesai
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pesanan Telah Selesai',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF339F16), width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFF339F16),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  const Text(
                    'Pesanan Anda Langsung\nBisa Di Ambil\nDiToko MbahMeth.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- Bottom Section ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Color(0xFF339F16), // Hijau dominan
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Kembali ke halaman beranda
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Kembali Ke Beranda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF339F16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terima Kasih sudah Berbelanja di Toko\nMbahMet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16), // Spasi bawah untuk indikator home iPhone
              ],
            ),
          ),
        ],
      ),
    );
  }
}

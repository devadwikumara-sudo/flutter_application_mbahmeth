import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  final int idOrder;
  final double totalHarga;
  final String metodePembayaran;
  final String metodeAmbil;
  final bool receiptSaved;

  const SuccessPage({
    super.key,
    required this.idOrder,
    required this.totalHarga,
    required this.metodePembayaran,
    required this.metodeAmbil,
    this.receiptSaved = false,
  });

  String _formatHarga(double nilai) {
    return 'Rp ${nilai.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- Fake iPhone Status Bar ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black),
                ),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_4_bar,
                        size: 16, color: Colors.black),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
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
                            border: Border.all(
                                color: const Color(0xFF339F16), width: 2),
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

                    // Info pesanan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                              label: 'No. Pesanan', value: '#$idOrder'),
                          const SizedBox(height: 8),
                          _InfoRow(
                              label: 'Total',
                              value: _formatHarga(totalHarga)),
                          const SizedBox(height: 8),
                          _InfoRow(
                              label: 'Pembayaran',
                              value: metodePembayaran),
                          const SizedBox(height: 8),
                          _InfoRow(
                              label: 'Pengambilan', value: metodeAmbil),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notif struk tersimpan
                    if (receiptSaved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF339F16)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: Color(0xFF339F16), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Struk berhasil disimpan ke galeri',
                              style: TextStyle(
                                color: Color(0xFF339F16),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Pesanan Anda Langsung\nBisa Di Ambil\nDi Toko MbahMeth.',
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
          ),

          // --- Bottom Section ---
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Color(0xFF339F16),
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
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
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
                  'Terima Kasih sudah Berbelanja di Toko MbahMeth',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      ), // end Scaffold
    ); // end PopScope
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF64748B))),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A))),
      ],
    );
  }
}
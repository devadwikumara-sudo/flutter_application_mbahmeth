import 'package:flutter/material.dart';
import 'success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // State untuk melacak pilihan metode pembayaran dan pengiriman
  String? _paymentMethod = 'Qris'; 
  String? _deliveryMethod; // Null agar user harus mengklik Ambil Di Toko

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      body: Column(
        children: [
          // --- Fake iPhone Status Bar (Sesuai Permintaan) ---
          Container(
            color: const Color(0xFF339F16), // Sesuai gambar, background status bar ikut hijau
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black), // Waktu di atas
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
          
          // --- Green App Bar ---
          Container(
            color: const Color(0xFF339F16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Pesan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Spacer agar teks pas di tengah
              ],
            ),
          ),

          // --- Scrollable Body ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. STEP PROGRESS ---
                  Container(
                    color: const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStep(1, 'Pembayaran', true),
                        _buildLine(), // Garis abu-abu kecil
                        _buildStep(2, 'ambil barang', true),
                        _buildLine(), 
                        _buildStep(3, 'Konfirmasi', true),
                      ],
                    ),
                  ),

                  // --- 2. METODE PEMBAYARAN ---
                  _buildSectionTitle('Metode Pembayaran'),
                  _buildCustomRadio(
                    title: 'Bayar Di Toko',
                    iconWidget: const Icon(Icons.storefront_outlined, color: Colors.black87),
                    value: 'Bayar Di Toko',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val),
                  ),
                  const SizedBox(height: 12),
                  _buildCustomRadio(
                    title: 'Qris',
                    // Icon sinyal sesuai di gambar
                    iconWidget: const Icon(Icons.sensors, color: Colors.black87), 
                    value: 'Qris',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val),
                  ),

                  const SizedBox(height: 24),

                  // --- 3. METODE PENGIRIMAN ---
                  _buildSectionTitle('Metode Pengiriman'),
                  _buildCustomRadio(
                    title: 'Ambil Di Toko',
                    iconWidget: const Icon(Icons.storefront_outlined, color: Colors.black87),
                    value: 'Ambil Di Toko',
                    groupValue: _deliveryMethod,
                    trailingText: 'Gratis',
                    onChanged: (val) => setState(() => _deliveryMethod = val),
                  ),

                  const SizedBox(height: 24),

                  // --- 4. KONFIRMASI ---
                  _buildSectionTitle('Konfirmasi'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF7ED), // Hijau pudar WA
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            // Memakai WA icon lokal, jika tidak ada, tampilkan icon bawaan flutter
                            child: Image.asset(
                              'assets/images/wa_icon.png', 
                              width: 24, height: 24,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.wechat, color: Color(0xFF339F16), size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order via WhatsApp',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Mengklik tombol di bawah ini akan\nmengirimkan\nrincian pesanan Anda ke WhatsApp resmi\nkami untuk pembayaran dan\nkonfirmasi.',
                                  style: TextStyle(color: Colors.black45, fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- 5. RINGKASAN PESANAN ---
                  _buildSectionTitle('Ringkasan Pesanan'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Item 1
                          _buildSummaryItem(
                            imagePath: 'assets/images/arjuna.png',
                            title: 'Arjuna - 200ec',
                            subtext: '2 x Rp. 26.000',
                            qty: '2',
                            price: 'Rp. 26.000',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.black12, thickness: 1),
                          ),
                          // Item 2
                          _buildSummaryItem(
                            imagePath: 'assets/images/pupuk.png',
                            title: 'KNO Merah',
                            subtext: '1 x Rp. 28.000',
                            qty: '1',
                            price: 'Rp. 56.000',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.black12, thickness: 1),
                          ),
                          // Totals
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: TextStyle(color: Colors.black87, fontSize: 14)),
                              Text('Rp. 82.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Biaya Pengiriman', style: TextStyle(color: Colors.black87, fontSize: 14)),
                              Text('Rp.2.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40), // Spasi longgar di akhir list
                ],
              ),
            ),
          ),
          
          // --- 6. BOTTOM SECTION (Total & Tombol Pesan) ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Harga',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Rp.84.000',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Wajib klik Ambil di Toko terlebih dahulu
                      if (_deliveryMethod == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan pilih metode pengiriman terlebih dahulu'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // Lanjut ke WhatsApp / Halaman Sukses
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SuccessPage()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF339F16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Klik Pesan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dengan mengklik tombol ini, detail pesanan Anda akan dikirim\nke WhatsApp resmi kami untuk pembayaran dan konfirmasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF339F16) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? const Color(0xFF339F16) : Colors.grey[400],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine() {
    return Container(
      width: 20,
      height: 1,
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      color: Colors.grey[400], // Garis penghubung abu-abu
    );
  }

  Widget _buildCustomRadio({
    required String title,
    required Widget iconWidget,
    required String value,
    required String? groupValue,
    required Function(String) onChanged,
    String? trailingText,
  }) {
    bool isSelected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: iconWidget,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: const TextStyle(color: Color(0xFF339F16), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              const SizedBox(width: 12),
              // Radio Button Hijau Kustom
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? const Color(0xFF339F16) : Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String imagePath,
    required String title,
    required String subtext,
    required String qty,
    required String price,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gambar bulat
        ClipOval(
          child: Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: const Color(0xFFF5F5F5),
              child: const Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtext, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Jumlah : ', style: TextStyle(color: Color(0xFF339F16), fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(qty, style: const TextStyle(color: Color(0xFF339F16), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

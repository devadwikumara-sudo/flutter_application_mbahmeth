import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/customer/success_page.dart';

class CheckoutPage extends StatefulWidget {
  final int idOrder;
  final List<Map<String, dynamic>> cartItems;
  final double totalHarga;
  final int userId;

  const CheckoutPage({
    super.key,
    required this.idOrder,
    required this.cartItems,
    required this.totalHarga,
    required this.userId,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod = 'Bayar Di Toko';
  String? _deliveryMethod;
  bool _isProcessing = false;
  final ApiService _api = ApiService();

  String _formatHarga(double nilai) {
    return nilai
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _prosesCheckout() async {
    if (_deliveryMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih metode pengambilan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final success = await _api.checkout(
      idOrder: widget.idOrder,
      metodePembayaran: _paymentMethod,
      metodeAmbil: _deliveryMethod!,
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPage()),
        (route) => route.isFirst, // Bersihkan stack sampai beranda
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal melakukan checkout. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header Hijau ──
          Container(
            color: const Color(0xFF339F16),
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Pesan',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),

          // ── Scrollable Content ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Progress
                  Container(
                    color: const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStep(1, 'Pembayaran', true),
                        _buildLine(),
                        _buildStep(2, 'Ambil Barang', true),
                        _buildLine(),
                        _buildStep(3, 'Konfirmasi', true),
                      ],
                    ),
                  ),

                  // ── 1. Ringkasan Pesanan ──
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
                          ...widget.cartItems.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final int jumlah = int.tryParse(
                                    item['jumlah']?.toString() ?? '1') ??
                                1;
                            final double subtotal = double.tryParse(
                                    item['subtotal']?.toString() ?? '0') ??
                                0;
                            final double hargaSatuan = double.tryParse(
                                    item['harga']?.toString() ?? '0') ??
                                0;

                            return Column(
                              children: [
                                _buildSummaryItem(
                                  gambarUrl:
                                      '${ApiService.imageUrl}${item['gambar_produk'] ?? ''}',
                                  title: item['nama_produk'] ?? '-',
                                  subtext:
                                      '$jumlah x Rp ${_formatHarga(hargaSatuan)}',
                                  qty: '$jumlah',
                                  subtotal: subtotal,
                                ),
                                if (i < widget.cartItems.length - 1)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10),
                                    child: Divider(
                                        color: Colors.black12, thickness: 1),
                                  ),
                              ],
                            );
                          }),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: Colors.black12, thickness: 1),
                          ),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                'Rp ${_formatHarga(widget.totalHarga)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF339F16)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 2. Metode Pembayaran ──
                  _buildSectionTitle('Metode Pembayaran'),
                  _buildCustomRadio(
                    title: 'Bayar Di Toko',
                    iconWidget: const Icon(Icons.storefront_outlined,
                        color: Colors.black87),
                    value: 'Bayar Di Toko',
                    groupValue: _paymentMethod,
                    onChanged: (val) =>
                        setState(() => _paymentMethod = val),
                  ),
                  const SizedBox(height: 12),
                  _buildCustomRadio(
                    title: 'Qris',
                    iconWidget: const Icon(Icons.qr_code_scanner,
                        color: Colors.black87),
                    value: 'Qris',
                    groupValue: _paymentMethod,
                    onChanged: (val) =>
                        setState(() => _paymentMethod = val),
                  ),

                  const SizedBox(height: 24),

                  // ── 3. Metode Ambil ──
                  _buildSectionTitle('Metode Pengambilan'),
                  _buildCustomRadio(
                    title: 'Ambil Di Toko',
                    iconWidget: const Icon(Icons.storefront_outlined,
                        color: Colors.black87),
                    value: 'Ambil Di Toko',
                    groupValue: _deliveryMethod,
                    trailingText: 'Gratis',
                    onChanged: (val) =>
                        setState(() => _deliveryMethod = val),
                  ),

                  const SizedBox(height: 24),

                  // ── 4. Konfirmasi Info ──
                  _buildSectionTitle('Konfirmasi'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF7ED),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.info_outline,
                                color: Color(0xFF339F16), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Konfirmasi Pesanan',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Pastikan data pesanan sudah benar sebelum melanjutkan. Setelah dikonfirmasi, stok akan langsung dikurangi dan pesanan Anda akan diproses.',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Bottom Tombol Pesan ──
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Pembayaran",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      "Rp ${_formatHarga(widget.totalHarga)}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF339F16)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _prosesCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF339F16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Konfirmasi Pesanan',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dengan menekan tombol ini, pesanan Anda akan diproses\ndan stok produk akan dikurangi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget Helpers ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(title,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            child: Text('$step',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? const Color(0xFF339F16)
                    : Colors.grey[400],
                fontWeight: isActive
                    ? FontWeight.bold
                    : FontWeight.normal)),
      ],
    );
  }

  Widget _buildLine() {
    return Container(
      width: 20,
      height: 1,
      margin:
          const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      color: Colors.grey[400],
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
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF339F16)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12)),
                child: iconWidget,
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600))),
              if (trailingText != null)
                Text(trailingText,
                    style: const TextStyle(
                        color: Color(0xFF339F16),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              const SizedBox(width: 12),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? const Color(0xFF339F16)
                    : Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String gambarUrl,
    required String title,
    required String subtext,
    required String qty,
    required double subtotal,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            gambarUrl,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.image_outlined,
                  color: Colors.grey, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 3),
              Text(subtext,
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Text('Jumlah: ',
                      style: TextStyle(
                          color: Color(0xFF339F16),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Text(qty,
                      style: const TextStyle(
                          color: Color(0xFF339F16),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Text(
          'Rp ${_formatHarga(subtotal)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
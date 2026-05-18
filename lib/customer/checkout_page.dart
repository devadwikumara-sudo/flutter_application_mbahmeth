import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/customer/success_page.dart';
import 'package:flutter_application_mbahmeth/customer/receipt_widget.dart';
import 'package:flutter_application_mbahmeth/customer/receipt_service.dart';

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
  String _namaPembeli = '';
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadNamaPembeli();
  }

  Future<void> _loadNamaPembeli() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _namaPembeli = prefs.getString('nama') ??
            prefs.getString('name') ??
            prefs.getString('nama_lengkap') ??
            '';
      });
    }
  }

  String _formatHarga(double nilai) {
    return nilai.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Simpan struk ke galeri menggunakan ReceiptService (off-screen render)
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> _saveReceiptToGallery() async {
    return ReceiptService.saveReceiptToGallery(
      child: ReceiptWidget(
        idOrder: widget.idOrder,
        cartItems: widget.cartItems,
        totalHarga: widget.totalHarga,
        metodePembayaran: _paymentMethod,
        metodeAmbil: _deliveryMethod ?? 'Ambil Di Toko',
        tanggal: DateTime.now(),
        namaPembeli: _namaPembeli,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Alur utama checkout
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _prosesCheckout() async {
    if (_deliveryMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Silakan pilih metode pengambilan terlebih dahulu'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // 1. Panggil API checkout
    final success = await _api.checkout(
      idOrder: widget.idOrder,
      metodePembayaran: _paymentMethod,
      metodeAmbil: _deliveryMethod!,
    );

    if (!success) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal melakukan checkout. Coba lagi.'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // 2. Tampilkan dialog struk + proses simpan ke galeri
    if (!mounted) return;
    _showReceiptSavingDialog();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dialog: preview struk + tombol simpan & lanjut
  // ─────────────────────────────────────────────────────────────────────────
  void _showReceiptSavingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ReceiptSavingDialog(
        receiptWidget: ReceiptWidget(
          idOrder: widget.idOrder,
          cartItems: widget.cartItems,
          totalHarga: widget.totalHarga,
          metodePembayaran: _paymentMethod,
          metodeAmbil: _deliveryMethod!,
          tanggal: DateTime.now(),
          namaPembeli: _namaPembeli,
        ),
        onSaveAndContinue: () async {
          Navigator.of(ctx).pop(); // tutup dialog

          // Simpan ke galeri
          final saved = await _saveReceiptToGallery();

          if (!mounted) return;
          setState(() => _isProcessing = false);

          if (!saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Struk gagal disimpan ke galeri, tapi pesanan berhasil!'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }

          // 3. Navigate ke SuccessPage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => SuccessPage(
                idOrder: widget.idOrder,
                totalHarga: widget.totalHarga,
                metodePembayaran: _paymentMethod,
                metodeAmbil: _deliveryMethod!,
                receiptSaved: saved,
              ),
            ),
            (route) => route.isFirst,
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 12, 16, 20),
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Konfirmasi Pesanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStepIndicator(),
              ],
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Ringkasan Pesanan'),
                  _buildOrderSummaryCard(),
                  const SizedBox(height: 20),

                  _buildSectionLabel('Metode Pembayaran'),
                  _buildOptionCard(
                    title: 'Bayar Di Toko',
                    icon: Icons.storefront_outlined,
                    value: 'Bayar Di Toko',
                    groupValue: _paymentMethod,
                    onChanged: (val) =>
                        setState(() => _paymentMethod = val),
                  ),
                  const SizedBox(height: 10),
                  _buildOptionCard(
                    title: 'QRIS',
                    icon: Icons.qr_code_scanner_rounded,
                    value: 'Qris',
                    groupValue: _paymentMethod,
                    onChanged: (val) =>
                        setState(() => _paymentMethod = val),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionLabel('Metode Pengambilan'),
                  _buildOptionCard(
                    title: 'Ambil Di Toko',
                    icon: Icons.storefront_outlined,
                    value: 'Ambil Di Toko',
                    groupValue: _deliveryMethod,
                    onChanged: (val) =>
                        setState(() => _deliveryMethod = val),
                    badge: 'Gratis',
                  ),
                  const SizedBox(height: 20),

                  // Info konfirmasi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.backgroundWhite,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline_rounded,
                              color: AppColors.primaryGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Penting',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pastikan data pesanan sudah benar. Setelah dikonfirmasi, stok akan dikurangi dan pesanan diproses.',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Bottom CTA ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran',
                        style: TextStyle(
                            color: AppColors.textMedium, fontSize: 13)),
                    Text(
                      'Rp ${_formatHarga(widget.totalHarga)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _prosesCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor:
                          AppColors.primaryGreen.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Konfirmasi & Bayar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ), // end Scaffold
    ); // end PopScope
  }

  // ── Helper builders ───────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep('Keranjang', Icons.shopping_cart_outlined, true),
        _buildStepLine(true),
        _buildStep('Checkout', Icons.receipt_long_outlined, true),
        _buildStepLine(false),
        _buildStep('Selesai', Icons.check_circle_outline_rounded, false),
      ],
    );
  }

  Widget _buildStep(String label, IconData icon, bool active) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: active ? AppColors.primaryGreen : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? Colors.white : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          ...widget.cartItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final subtotal = double.tryParse(
                      item['subtotal']?.toString() ?? '0',
                    ) ??
                (double.tryParse(item['harga']?.toString() ?? '0') ?? 0) *
                    (int.tryParse(item['jumlah']?.toString() ?? '1') ?? 1);

            return Column(
              children: [
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppColors.divider, thickness: 1),
                  ),
                _buildSummaryItem(
                  gambarUrl:
                      '${ApiService.imageUrl}${item['gambar_produk']?.toString() ?? ''}',
                  title: item['nama_produk']?.toString() ??
                      item['name']?.toString() ??
                      '-',
                  subtext:
                      'Rp ${_formatHarga(double.tryParse(item['harga']?.toString() ?? '0') ?? 0)} / item',
                  qty: item['jumlah']?.toString() ?? '1',
                  subtotal: subtotal,
                ),
              ],
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.divider, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Rp ${_formatHarga(widget.totalHarga)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required String value,
    required String? groupValue,
    required Function(String) onChanged,
    String? badge,
  }) {
    final bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected ? AppColors.greenShadow : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.successLight
                    : AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.textDark
                          : AppColors.textMedium,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textLight,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primaryGreen
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ],
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
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            gambarUrl,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 58,
              height: 58,
              color: AppColors.successLight,
              child: const Icon(Icons.eco_rounded,
                  color: AppColors.primaryGreen, size: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                subtext,
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Qty: $qty',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Rp ${_formatHarga(subtotal)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog preview struk + tombol simpan & lanjut
// ─────────────────────────────────────────────────────────────────────────────
class _ReceiptSavingDialog extends StatefulWidget {
  final Widget receiptWidget;
  final VoidCallback onSaveAndContinue;

  const _ReceiptSavingDialog({
    required this.receiptWidget,
    required this.onSaveAndContinue,
  });

  @override
  State<_ReceiptSavingDialog> createState() => _ReceiptSavingDialogState();
}

class _ReceiptSavingDialogState extends State<_ReceiptSavingDialog> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Struk preview ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: widget.receiptWidget,
            ),
          ),
          const SizedBox(height: 16),

          // ── Tombol simpan & lanjut ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saving
                  ? null
                  : () {
                      setState(() => _saving = true);
                      widget.onSaveAndContinue();
                    },
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_alt_rounded, size: 20),
              label: Text(
                _saving ? 'Menyimpan struk...' : 'Simpan Struk & Lanjut',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF339F16),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
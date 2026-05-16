import 'package:flutter/material.dart';

/// Widget struk pesanan — dipakai oleh ReceiptService untuk di-screenshot.
/// Bisa juga ditampilkan di dalam dialog/modal sebelum disimpan.
class ReceiptWidget extends StatelessWidget {
  final int idOrder;
  final List<Map<String, dynamic>> cartItems;
  final double totalHarga;
  final String metodePembayaran;
  final String metodeAmbil;
  final DateTime tanggal;
  final String namaPembeli;

  const ReceiptWidget({
    super.key,
    required this.idOrder,
    required this.cartItems,
    required this.totalHarga,
    required this.metodePembayaran,
    required this.metodeAmbil,
    required this.tanggal,
    this.namaPembeli = '',
  });

  String _formatHarga(double nilai) {
    return 'Rp ${nilai.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String _formatTanggal(DateTime dt) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${bulan[dt.month]} ${dt.year}, $jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header hijau gradient ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F6B00), Color(0xFF4BBE1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // ── Logo + nama toko ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/images/x1.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.eco_rounded,
                              color: Color(0xFF339F16),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MbahMeth',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Toko Pertanian Terpercaya',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Badge "STRUK PEMBELIAN" ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.35), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 13),
                      SizedBox(width: 6),
                      Text(
                        'STRUK PEMBELIAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Zig-zag pemisah ───────────────────────────────────────────────
          _ZigZagDivider(color: const Color(0xFF4BBE1A)),

          // ── Body struk ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                // ── Info pesanan ──
                _ReceiptRow(
                    label: 'No. Pesanan',
                    value: '#$idOrder',
                    valueColor: const Color(0xFF339F16)),
                if (namaPembeli.isNotEmpty)
                  _ReceiptRow(label: 'Pembeli', value: namaPembeli),
                _ReceiptRow(
                    label: 'Tanggal', value: _formatTanggal(tanggal)),
                _ReceiptRow(
                    label: 'Pembayaran', value: metodePembayaran),
                _ReceiptRow(label: 'Pengambilan', value: metodeAmbil),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: _DashedDivider(),
                ),

                // ── Header tabel produk ──
                Row(
                  children: const [
                    Expanded(
                      flex: 5,
                      child: Text(
                        'Produk',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        'Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Subtotal',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Daftar produk ──
                ...cartItems.map((item) {
                  final nama = item['nama_produk']?.toString() ??
                      item['name']?.toString() ??
                      '-';
                  final qty = item['jumlah']?.toString() ?? '1';
                  final subtotal = double.tryParse(
                            item['subtotal']?.toString() ?? '0',
                          ) ??
                      (double.tryParse(
                                  item['harga']?.toString() ?? '0') ??
                              0) *
                          (int.tryParse(
                                  item['jumlah']?.toString() ?? '1') ??
                              1);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            qty,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _formatHarga(subtotal),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: _DashedDivider(),
                ),

                // ── Total box ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFBBF7D0), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.payments_rounded,
                              color: Color(0xFF339F16), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatHarga(totalHarga),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF339F16),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Barcode dekoratif ──
                const _DashedDivider(),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: CustomPaint(painter: _BarcodePainter()),
                ),
                const SizedBox(height: 12),

                // ── Footer ──
                const Text(
                  'Terima kasih sudah berbelanja\ndi Toko MbahMeth! 🌿',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ReceiptRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final totalWidth = constraints.maxWidth;
        final count = (totalWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(count, (_) {
            return Padding(
              padding: const EdgeInsets.only(right: dashSpace),
              child: Container(
                width: dashWidth,
                height: 1,
                color: const Color(0xFFCBD5E1),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Zig-zag pemisah antara header dan body struk
class _ZigZagDivider extends StatelessWidget {
  final Color color;
  const _ZigZagDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 16),
      painter: _ZigZagPainter(color: color),
    );
  }
}

class _ZigZagPainter extends CustomPainter {
  final Color color;
  _ZigZagPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    const step = 16.0;
    var x = 0.0;
    while (x < size.width) {
      path.lineTo(x + step / 2, size.height);
      path.lineTo(x + step, 0);
      x += step;
    }
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ZigZagPainter old) => old.color != color;
}

/// Barcode dekoratif untuk estetika struk
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF94A3B8);
    final widths = [
      2.0, 1.0, 3.0, 1.0, 2.0, 1.5, 4.0, 1.0, 2.0, 1.5,
      3.0, 1.0, 2.0, 1.5, 1.0, 3.0, 2.0, 1.0, 2.0, 1.5,
      3.0, 1.0, 2.0, 1.5, 1.0, 2.5, 3.0, 1.0, 2.0, 1.0
    ];
    double x = 0;
    bool draw = true;
    for (final w in widths) {
      if (draw) {
        canvas.drawRect(
          Rect.fromLTWH(x, size.height * 0.1, w * 3, size.height * 0.8),
          paint,
        );
      }
      x += w * 3 + 2;
      if (x > size.width) break;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => false;
}
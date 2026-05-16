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

  const ReceiptWidget({
    super.key,
    required this.idOrder,
    required this.cartItems,
    required this.totalHarga,
    required this.metodePembayaran,
    required this.metodeAmbil,
    required this.tanggal,
  });

  String _formatHarga(double nilai) {
    return 'Rp ${nilai.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String _formatTanggal(DateTime dt) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
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
          // ── Header hijau ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF339F16),
            ),
            child: Column(
              children: [
                // Logo placeholder (Icon toko)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.store_mall_directory_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Toko MbahMeth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Struk Pembelian',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ── Zig-zag pemisah ───────────────────────────────────────────────
          _ZigZagDivider(color: const Color(0xFF339F16)),

          // ── Body struk ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 4),

                // No. pesanan & tanggal
                _ReceiptRow(label: 'No. Pesanan', value: '#$idOrder'),
                _ReceiptRow(label: 'Tanggal', value: _formatTanggal(tanggal)),
                _ReceiptRow(label: 'Pembayaran', value: metodePembayaran),
                _ReceiptRow(label: 'Pengambilan', value: metodeAmbil),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: _DashedDivider(),
                ),

                // Header produk
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
                      width: 40,
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

                // Daftar produk
                ...cartItems.map((item) {
                  final nama = item['nama_produk']?.toString() ??
                      item['name']?.toString() ?? '-';
                  final qty = item['jumlah']?.toString() ?? '1';
                  final subtotal = double.tryParse(
                        item['subtotal']?.toString() ?? '0',
                      ) ??
                      (double.tryParse(item['harga']?.toString() ?? '0') ?? 0) *
                          (int.tryParse(item['jumlah']?.toString() ?? '1') ?? 1);

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
                          width: 40,
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

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 1,
                      ),
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

                const SizedBox(height: 20),

                // Footer
                const _DashedDivider(),
                const SizedBox(height: 16),
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
  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
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
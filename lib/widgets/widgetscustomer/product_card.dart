import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';

/// Kartu produk modern untuk panel admin.
/// Menampilkan gambar, nama, harga, stok dengan warna dinamis,
/// serta tombol edit dan hapus yang bersih.
class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final int stock;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? category; // opsional badge kategori

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.onEdit,
    required this.onDelete,
    this.category,
  });

  // ── Warna & label stok ──────────────────────────────────────────────────
  Color get _stockColor {
    if (stock == 0) return AppColors.primaryRed;
    if (stock < 20) return AppColors.warning;
    return AppColors.primaryGreen;
  }

  Color get _stockBgColor {
    if (stock == 0) return AppColors.primaryRedLight;
    if (stock < 20) return AppColors.warningLight;
    return AppColors.successLight;
  }

  IconData get _stockIcon {
    if (stock == 0) return Icons.remove_circle_outline_rounded;
    if (stock < 20) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline_rounded;
  }

  String get _stockLabel {
    if (stock == 0) return 'Habis';
    if (stock < 20) return 'Hampir Habis';
    return 'Tersedia';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // ── Baris utama ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar produk
                _buildImage(),
                const SizedBox(width: 14),

                // Info produk
                Expanded(child: _buildInfo()),

                // Menu titik tiga
                _buildMoreMenu(context),
              ],
            ),
          ),

          // ── Footer: stok bar ─────────────────────────────────────────
          _buildStockFooter(),
        ],
      ),
    );
  }

  // ── Gambar ──────────────────────────────────────────────────────────────
  Widget _buildImage() {
    final String url = imageUrl.isNotEmpty
        ? imageUrl
        : 'https://raw.githubusercontent.com/mbahmeth/mbahmeth-admin/main/assets/images/placeholder.png';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.successLight,
            child: const Icon(
              Icons.eco_rounded,
              color: AppColors.primaryGreen,
              size: 32,
            ),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.surfaceGrey,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Info teks ────────────────────────────────────────────────────────────
  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge kategori
        if (category != null) ...[
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              category!.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreenDark,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Nama produk
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.textDark,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),

        // Harga
        Text(
          price,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),

        // Chip stok
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _stockBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_stockIcon, size: 13, color: _stockColor),
              const SizedBox(width: 4),
              Text(
                'Stok $stock  •  $_stockLabel',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _stockColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── PopupMenu ────────────────────────────────────────────────────────────
  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.grey.shade400,
        size: 22,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      offset: const Offset(0, 36),
      onSelected: (val) {
        if (val == 'edit') onEdit();
        if (val == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit_rounded,
                    color: Colors.blue.shade600, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Edit Produk',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryRedLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_rounded,
                    color: AppColors.primaryRed, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Hapus Produk',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryRed)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Footer stok bar ──────────────────────────────────────────────────────
  Widget _buildStockFooter() {
    // Asumsikan stok max ~100 untuk progress bar visual
    final double progress = (stock / 100).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_stockColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$stock unit',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _stockColor,
            ),
          ),
        ],
      ),
    );
  }
}
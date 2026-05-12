import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final int stock;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Logika warna stok
    Color stockColor = Colors.green;
    if (stock < 20) stockColor = Colors.orange;
    if (stock == 0) stockColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Shadow sangat tipis
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 70,
            height: 70,
            color: Colors.grey[100], // Background tipis jika gambar gagal
            child: Image.network(
              // URL JIKA GAMBAR TIDAK TERSEDIA
              imageUrl.isNotEmpty ? imageUrl : 'https://raw.githubusercontent.com/mbahmeth/mbahmeth-admin/main/assets/images/placeholder.png', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 30),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFF2E9900),
                fontWeight: FontWeight.bold, 
                fontSize: 15
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Stok: $stock",
              style: TextStyle(
                color: stockColor, // Warna stok dinamis
                fontSize: 12,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        trailing: Wrap(
          spacing: -5, // Merapatkan jarak tombol aksi
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

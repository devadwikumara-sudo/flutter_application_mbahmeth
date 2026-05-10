import 'package:flutter/material.dart';
import 'keranjang_page.dart';

class DeskripsiPage extends StatefulWidget {
  const DeskripsiPage({super.key});

  @override
  State<DeskripsiPage> createState() => _DeskripsiPageState();
}

class _DeskripsiPageState extends State<DeskripsiPage> {
  // State untuk menyimpan jumlah pesanan
  int quantity = 1; // Default 1 sesuai gambar

  void increment() {
    setState(() {
      quantity++;
    });
  }

  void decrement() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Latar belakang abu-abu sangat muda
      // Menggunakan bottomNavigationBar agar selalu di bawah dan tidak menutupi scroll
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF339F16), // Hijau dominan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            label: const Text(
              'Masukkan Keranjang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Konten yang bisa di-scroll
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Product Image Section ---
                // Gambar Utama dengan ClipRRect agar melengkung di bawah
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3, // Menjaga proporsi gambar agar tidak gepeng di layar pendek
                    child: Image.asset(
                      'assets/images/arjuna.png', // Silakan masukkan gambar ke folder ini
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback jika gambar belum ada
                        return Container(
                          color: const Color(0xFFE0E0E0),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Gambar Produk', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
            
            // --- 3. Title and Price Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Inteksida Arjuna\n200 EC',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        height: 1.2, 
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    'Rp. 28.000',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // --- 4. Description Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown[600], 
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Arjuna 200 EC adalah insektisida kontak, perut, dan pernapasan berbahan aktif Klorfenapir 200 g/l berbentuk pekatan cair. Efektif mengendalikan ulat grayak, dan kutu daun',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // --- 5. Quantity Section (Sesuai Gambar) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3D6), // Hijau muda cerah sesuai gambar
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jumlah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800], // Coklat gelap
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white, // Latar putih untuk pill counter
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // Tombol Minus
                          GestureDetector(
                            onTap: decrement,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.remove, 
                                color: quantity > 1 ? Colors.grey[600] : Colors.grey[300], 
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Angka
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey, // Warna angka abu-abu sesuai gambar
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tombol Plus
                          GestureDetector(
                            onTap: increment,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF288B11), // Lingkaran hijau tua
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40), // Spasi bawah agar tidak mentok
          ],
        ),
      ),
      
      // --- 2. Back Button (Fixed Position) ---
      // Karena berada di luar SingleChildScrollView, tombol ini tidak akan ikut ter-scroll (tetap diam)
      Positioned(
        top: MediaQuery.of(context).padding.top + 16, // Aman dari poni HP
        left: 20,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Latar transparan gelap
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
        ),
      ),
    ],
  ),
);
  }
}

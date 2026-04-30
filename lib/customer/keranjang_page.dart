import 'package:flutter/material.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Data dummy untuk keranjang
  final List<Map<String, dynamic>> cartItems = [
    {
      'id': 'Order #Insekti-200ec-001',
      'price': '40.000',
      'quantity': 2,
      'image': 'assets/images/arjuna.png', 
    },
    {
      'id': 'Order #Pupuk-KNO M-002',
      'price': '45.000',
      'quantity': 2,
      'image': 'assets/images/pupuk.png', 
    },
    {
      'id': 'Order#Bibit-Perkasa-003',
      'price': '80.000',
      'quantity': 2,
      'image': 'assets/images/bibit.png', 
    },
  ];

  void incrementQuantity(int index) {
    setState(() {
      cartItems[index]['quantity']++;
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Latar belakang abu-abu terang
      
      // --- APP BAR ---
      // AppBar otomatis tetap diam (fixed) di atas saat konten di-scroll
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        scrolledUnderElevation: 0, // Mencegah perubahan warna saat di-scroll
        leadingWidth: 64, // Memberikan ruang cukup untuk tombol bulat
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD8F3D6), // Hijau muda bulat
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      // --- BODY (Daftar Keranjang) ---
      // Menggunakan ListView agar bisa di-scroll dengan mulus di bawah AppBar
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Sudut melengkung besar seperti gambar
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Kiri: Teks & Counter ---
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 8, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['id'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF339F16)),
                            const SizedBox(width: 6),
                            Text(
                              'Rp. ${item['price']}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Tombol - / Angka / +
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF288B11), // Hijau gelap
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => decrementQuantity(index),
                                child: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${item['quantity']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => incrementQuantity(index),
                                child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Kanan: Gambar Produk ---
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 1, // Memastikan gambar selalu proporsional persegi
                        child: Image.asset(
                          item['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF0F0F0),
                            child: const Center(
                              child: Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // --- BOTTOM NAVIGATION (Dua Tombol) ---
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: const Text(
                      'Tambah Pesanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF288B11),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Lanjut ke halaman checkout
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutPage(),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    color: const Color(0xFFD8F3D6), // Hijau pucat
                    child: const Text(
                      'Buat Pesanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF288B11),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int jumlah = 1;
  int stokMax = 15; // Diambil dari DB

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/arjuna.jpg', width: double.infinity, height: 300, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Insektisida Arjuna", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("Rp 28.000", style: TextStyle(fontSize: 18, color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Arjuna 200 EC adalah insektisida racun kontak..."),
                  SizedBox(height: 30),
                  
                  // Counter Jumlah
                  Row(
                    children: [
                      Text("Jumlah"),
                      Spacer(),
                      IconButton(onPressed: () => setState(() => jumlah > 1 ? jumlah-- : null), icon: Icon(Icons.remove_circle_outline)),
                      Text("$jumlah"),
                      IconButton(onPressed: () => setState(() => jumlah < stokMax ? jumlah++ : null), icon: Icon(Icons.add_circle_outline)),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Tombol Keranjang
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.all(15)),
                      onPressed: stokMax > 0 ? () {} : null,
                      child: Text(stokMax > 0 ? "Masukkan Keranjang" : "Stok Habis"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
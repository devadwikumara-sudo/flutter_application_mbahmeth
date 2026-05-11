import 'package:flutter/material.dart';
// Sesuaikan import ini karena order_card sudah satu folder di customer
import 'order_card.dart'; 

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E9900),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Pakai leading ini kalau dibuka sebagai halaman mandiri (push)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          OrderCard(
            orderId: '8492',
            status: 'Selesai',
            date: '24 Okt 2026 • 10:30 WIB',
            itemName: 'KNO Merah',
            price: '28.000',
            statusColor: Color(0xFF2E9900),
          ),
          OrderCard(
            orderId: '8495',
            status: 'Diproses',
            date: 'Hari ini • 14:15 WIB',
            itemName: 'Genset TGR',
            price: '28.000',
            statusColor: Colors.orange,
          ),
          OrderCard(
            orderId: '8498',
            status: 'Menunggu',
            date: 'Hari ini • 15:45 WIB',
            itemName: 'Insektisida Arjuna 200',
            price: '26.000',
            statusColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
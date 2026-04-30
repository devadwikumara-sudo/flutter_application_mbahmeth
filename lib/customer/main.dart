import 'package:flutter/material.dart';
import 'deskripsi_page.dart'; // Memanggil halaman deskripsi produk yang sudah dipisah

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App Checkout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        // Gunakan font yang bersih seperti Roboto atau Inter jika ada
      ),
      home: const DeskripsiPage(),
    );
  }
}
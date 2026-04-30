import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Checkout(),
    );
  }
}

class Checkout extends StatefulWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  int selectedPayment = 0;
  int selectedDelivery = 0;
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F9901),
        title: Text(isSuccess ? "Selesai" : "Pesan"),
        centerTitle: true,
      ),
      body: isSuccess ? _successView() : _checkoutView(),
    );
  }

  // ================= CHECKOUT =================
  Widget _checkoutView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            StepItem(number: "1", label: "Pembayaran"),
            Expanded(child: Divider()),
            StepItem(number: "2", label: "Ambil"),
            Expanded(child: Divider()),
            StepItem(number: "3", label: "Konfirmasi"),
          ],
        ),

        const SizedBox(height: 20),

        const Text("Metode Pembayaran",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        PaymentCard(
          title: "Bayar Di Toko",
          selected: selectedPayment == 0,
          onTap: () => setState(() => selectedPayment = 0),
        ),

        PaymentCard(
          title: "QRIS",
          selected: selectedPayment == 1,
          onTap: () => setState(() => selectedPayment = 1),
        ),

        const SizedBox(height: 20),

        const Text("Metode Pengiriman",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        PaymentCard(
          title: "Ambil Di Toko (Gratis)",
          selected: selectedDelivery == 0,
          onTap: () => setState(() => selectedDelivery = 0),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Order via WhatsApp\n\nKlik tombol di bawah untuk kirim pesanan.",
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Total Harga"),
            Text("Rp 84.000",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F9901),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: const StadiumBorder(),
          ),
          onPressed: () {
            setState(() {
              isSuccess = true;
            });
          },
          child: const Text("Klik Pesan"),
        ),
      ],
    );
  }

  // ================= SUCCESS =================
  Widget _successView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),

            const SizedBox(height: 20),

            const Text(
              "Pesanan Telah Selesai",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Pesanan Anda bisa langsung diambil di Toko MbahMeth.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2F9901),
                side: const BorderSide(color: Color(0xFF2F9901)),
              ),
              onPressed: () {
                setState(() {
                  isSuccess = false;
                });
              },
              child: const Text("Kembali Ke Beranda"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Terima kasih sudah berbelanja",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= COMPONENT =================

class StepItem extends StatelessWidget {
  final String number;
  final String label;

  const StepItem({Key? key, required this.number, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF2F9901),
          child: Text(number,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class PaymentCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const PaymentCard({
    Key? key,
    required this.title,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.green,
            )
          ],
        ),
      ),
    );
  }
}

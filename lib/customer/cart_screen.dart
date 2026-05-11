import 'package:flutter/material.dart';

// --- KITA PAKAI WARNA LANGSUNG BIAR GAK ERROR IMPORT THEME ---
const Color primaryGreen = Color(0xFF2E9900);

class CartContent extends StatelessWidget {
  const CartContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              CartItem(
                productName: 'INTEKSIDA ARJUNA 200',
                price: '7.000',
                quantity: 2,
              ),
              SizedBox(height: 16),
              CartItem(
                productName: 'CIHERANG 5KG',
                price: '65.000',
                quantity: 1,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Rp. 200.000',
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout berhasil!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                  ),
                  child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const CartContent(),
    );
  }
}

class CartItem extends StatefulWidget {
  final String productName;
  final String price;
  final int quantity;

  const CartItem({
    super.key,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  late int _qty;

  @override
  void initState() {
    super.initState();
    _qty = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 70, 
          height: 70, 
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10)
          )
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Rp. ${widget.price}', style: const TextStyle(color: primaryGreen)),
              Row(
                children: [
                  IconButton(
                    onPressed: () { if (_qty > 1) setState(() => _qty--); },
                    icon: const Icon(Icons.remove_circle_outline, color: primaryGreen),
                  ),
                  Text(_qty.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => setState(() => _qty++),
                    icon: const Icon(Icons.add_circle_outline, color: primaryGreen),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
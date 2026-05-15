import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';
import 'package:flutter_application_mbahmeth/customer/checkout_page.dart';

class CartPage extends StatefulWidget {
  final int userId;
  final int currentIndex;
  final void Function(int)? onNavTap;

  const CartPage({
    super.key,
    required this.userId,
    this.currentIndex = 1,
    this.onNavTap,
  });

  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _error;

  int? _idOrder;
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  // ── FIX Bug 1: Reload keranjang setiap kali halaman menjadi aktif kembali ──
  @override
  void didUpdateWidget(covariant CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika userId berubah (ganti akun), reload keranjang
    if (oldWidget.userId != widget.userId) {
      loadCart();
    }
  }

  Future<void> loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Jika userId belum ada (belum login), langsung tampilkan kosong
    if (widget.userId == 0) {
      setState(() {
        _idOrder = null;
        _cartItems = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await _api.getCart(widget.userId);

      // ── FIX Bug 1 UTAMA: Tangani status 'success' DAN 'empty' ──
      // Sebelumnya hanya cek 'success', sehingga ketika server kirim 'empty'
      // (keranjang kosong), kondisi else men-set _error dan tampilkan error state.
      if (data['status'] == 'success' || data['status'] == 'empty') {
        setState(() {
          _idOrder = data['id_order'] != null
              ? int.tryParse(data['id_order'].toString())
              : null;
          _cartItems =
              List<Map<String, dynamic>>.from(data['items'] ?? []);
          _isLoading = false;
        });
      } else {
        // Hanya masuk sini jika benar-benar ada error dari server
        setState(() {
          _error = data['message']?.toString() ?? 'Gagal memuat keranjang';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double get totalHarga {
    return _cartItems.fold(0, (sum, item) {
      final subtotal =
          double.tryParse(item['subtotal']?.toString() ?? '0') ?? 0;
      return sum + subtotal;
    });
  }

  String _formatHarga(double nilai) {
    return nilai
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _updateJumlah(int index, int newJumlah) async {
    final item = _cartItems[index];
    final idDetail =
        int.tryParse(item['id_detail']?.toString() ?? '0') ?? 0;

    if (newJumlah < 1) return;

    final stokMax =
        int.tryParse(item['stok']?.toString() ?? '0') ?? 0;
    if (newJumlah > stokMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Stok hanya tersisa $stokMax"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final harga =
        double.tryParse(item['harga']?.toString() ?? '0') ?? 0;
    setState(() {
      _cartItems[index]['jumlah'] = newJumlah;
      _cartItems[index]['subtotal'] =
          (harga * newJumlah).toStringAsFixed(2);
    });

    await _api.updateCartItem(idDetail: idDetail, jumlah: newJumlah);
  }

  Future<void> _hapusItem(int index) async {
    final idDetail =
        int.tryParse(_cartItems[index]['id_detail']?.toString() ?? '0') ??
            0;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Hapus Item",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Yakin ingin menghapus \"${_cartItems[index]['nama_produk'] ?? 'produk ini'}\" dari keranjang?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal",
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _api.deleteCartItem(idDetail);
      loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF339F16)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text("Gagal memuat keranjang"),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF339F16)),
                        onPressed: loadCart,
                        child: const Text("Coba Lagi",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : widget.userId == 0
                  // ── FIX: Tampilkan pesan login jika belum login ──
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline,
                              size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text("Silakan login terlebih dahulu",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : _cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart_outlined,
                                  size: 80, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text("Keranjang masih kosong",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF339F16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () {
                                  if (widget.onNavTap != null) {
                                    widget.onNavTap!(0);
                                  } else if (Navigator.canPop(context)) {
                                    // Jika halaman ini dibuka sebagai modal/push, baru gunakan pop
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text("Mulai Belanja",
                                  style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            final int jumlah = int.tryParse(
                                    item['jumlah']?.toString() ?? '1') ??
                                1;
                            final double subtotal = double.tryParse(
                                    item['subtotal']?.toString() ?? '0') ??
                                0;

                            return Dismissible(
                              key: Key(item['id_detail'].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete_outline,
                                        color: Colors.red, size: 28),
                                    const SizedBox(height: 4),
                                    Text('Hapus',
                                        style: TextStyle(
                                            color: Colors.red.shade400,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              confirmDismiss: (_) async {
                                await _hapusItem(index);
                                return false;
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2))
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // ── Kiri: Info & Counter ──
                                        Expanded(
                                          flex: 5,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.fromLTRB(
                                                    16, 16, 8, 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['nama_produk'] ?? '-',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF1E293B)),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.payments_outlined,
                                                        size: 14,
                                                        color:
                                                            Color(0xFF339F16)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Rp ${_formatHarga(double.tryParse(item['harga']?.toString() ?? '0') ?? 0)} / item",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Subtotal: Rp ${_formatHarga(subtotal)}",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF339F16)),
                                                ),
                                                const SizedBox(height: 12),
                                                // ── Counter jumlah ──
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF288B11),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () =>
                                                            _updateJumlah(
                                                                index,
                                                                jumlah - 1),
                                                        child: const Icon(
                                                            Icons
                                                                .remove_circle_outline,
                                                            color: Colors.white,
                                                            size: 20),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        '$jumlah',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            _updateJumlah(
                                                                index,
                                                                jumlah + 1),
                                                        child: const Icon(
                                                            Icons
                                                                .add_circle_outline,
                                                            color: Colors.white,
                                                            size: 20),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // ── Kanan: Gambar ──
                                        Expanded(
                                          flex: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Image.network(
                                                  '${ApiService.imageUrl}${item['gambar_produk'] ?? ''}',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    color: const Color(
                                                        0xFFF0F0F0),
                                                    child: const Center(
                                                        child: Icon(
                                                            Icons.image_outlined,
                                                            color: Colors.grey,
                                                            size: 36)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // ── Baris bawah: tombol Hapus eksplisit ──
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                bottom: Radius.circular(24)),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextButton.icon(
                                              onPressed: () =>
                                                  _hapusItem(index),
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 16,
                                                  color: Colors.red),
                                              label: const Text(
                                                'Hapus',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          Container(
                                              width: 1,
                                              height: 20,
                                              color: Colors.grey.shade200),
                                          Expanded(
                                            child: TextButton.icon(
                                              onPressed: () {
                                                if (widget.onNavTap != null) {
                                                  widget.onNavTap!(0);
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              icon: const Icon(
                                                  Icons.add_shopping_cart,
                                                  size: 16,
                                                  color: Color(0xFF339F16)),
                                              label: const Text(
                                                'Tambah',
                                                style: TextStyle(
                                                    color: Color(0xFF339F16),
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

      // ── Bottom: Checkout bar (jika ada item) ──
      bottomNavigationBar: _cartItems.isNotEmpty
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Belanja",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              "Rp ${_formatHarga(totalHarga)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF339F16),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${_cartItems.length} item",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (widget.onNavTap != null) {
                                widget.onNavTap!(0);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.white,
                              child: const Text(
                                'Tambah Pesanan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF288B11),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: InkWell(
                            onTap: _idOrder != null
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CheckoutPage(
                                          idOrder: _idOrder!,
                                          cartItems: _cartItems,
                                          totalHarga: totalHarga,
                                          userId: widget.userId,
                                        ),
                                      ),
                                    // ── FIX Bug 4: Reload keranjang setelah kembali dari checkout ──
                                    ).then((_) => loadCart());
                                  }
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              color: const Color(0xFFD8F3D6),
                              child: const Text(
                                'Buat Pesanan',
                                style: TextStyle(
                                  fontSize: 14,
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

                  const SizedBox(height: 10),
                ],
              ),
            )
          : null,
    );
  }
}
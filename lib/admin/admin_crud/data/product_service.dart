import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_mbahmeth/models/modelsadmin/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/modelsadmin/product_model.dart';

class ProductService {
  // Alamat API 
  final String _baseUrl = "http://172.16.115.174/api_pertanian/produk";

  // --- 1. TAMBAH PRODUK ---
  Future<bool> addProduct(ProductModel product, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/create.php"),
      );

      // SINKRONISASI KEY Sesuaikan dengan $_POST di create.php
      request.fields['name'] = product.name;
      request.fields['price'] = product.price.toString();
      request.fields['stock'] = product.stock.toString();
      request.fields['category'] = product.category ?? '';
      request.fields['description'] = product.description ?? '';

      // Penanganan Gambar (Key: 'image_file' sesuai revisi create.php sebelumnya)
      if (imageFile != null) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image_file', // Key ini harus SAMA dengan $_FILES di PHP
          bytes,
          filename: imageFile.name,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("Error addProduct: $e");
      return false;
    }
  }

  // --- 2. AMBIL SEMUA PRODUK ---
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/read.php"));
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => ProductModel.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error getProducts: $e");
      return [];
    }
  }

  // --- 3. UPDATE PRODUK ---
  Future<bool> updateProduct(ProductModel product, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/update.php"),
      );

      // Data update
      request.fields['id_produk'] = product.id.toString();
      request.fields['name'] = product.name;
      request.fields['price'] = product.price.toString();
      request.fields['stock'] = product.stock.toString();
      request.fields['category'] = product.category ?? '';
      request.fields['description'] = product.description ?? '';

      if (imageFile != null) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image_file',
          bytes,
          filename: imageFile.name,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("Error updateProduct: $e");
      return false;
    }
  }

  // --- 4. HAPUS PRODUK ---
  Future<bool> deleteProduct(int id) async {
    try {
      // Menggunakan query parameter ?id= agar lebih mudah ditangkap PHP
      final response = await http.get(
        Uri.parse("$_baseUrl/delete.php?id=$id"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("Error deleteProduct: $e");
      return false;
    }
  }
}
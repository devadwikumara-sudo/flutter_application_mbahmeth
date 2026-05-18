import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ================================================================
// GANTI baseUrl sesuai IP/localhost server PHP kamu
// Emulator Android  → http://localhost/TOKO_MBAHMETH/api/admin/get_users.php
// Device fisik      → http://192.168.x.x/tokombahmet/get_users.php
// ================================================================
const String baseUrl = "http://localhost/TOKO_MBAHMETH/api/admin/get_users.php";

class UsersSemua extends StatefulWidget {
  const UsersSemua({super.key});

  @override
  State<UsersSemua> createState() => _UsersSemuaState();
}

class _UsersSemuaState extends State<UsersSemua> {
  int selectedTab = 0;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredBySearch = [];

  bool isLoading = true;
  String errorMsg = "";
  String searchQuery = "";

  // ---- Warna badge berdasarkan role ----
  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case "admin":
        return Colors.blue;
      case "pelanggan":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ---- Fetch data dari API ----
  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMsg = "";
    });

    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json["status"] == "success") {
          final List<dynamic> data = json["data"];
          setState(() {
            users = data.map((e) => Map<String, dynamic>.from(e)).toList();
            filteredBySearch = users;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMsg = json["message"] ?? "Gagal memuat data";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMsg = "Server error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "Tidak dapat terhubung ke server.\nPastikan API aktif.";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ---- Filter berdasarkan tab ----
  List<Map<String, dynamic>> get filteredUsers {
    List<Map<String, dynamic>> result = filteredBySearch;

    if (selectedTab == 1) {
      result = result.where((e) => e["role"].toLowerCase() == "admin").toList();
    } else if (selectedTab == 2) {
      result =
          result.where((e) => e["role"].toLowerCase() == "pelanggan").toList();
    }
    return result;
  }

  // ---- Filter berdasarkan search ----
  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredBySearch = users;
      } else {
        filteredBySearch = users.where((e) {
          final nama = e["nama_lengkap"].toString().toLowerCase();
          final email = e["email"].toString().toLowerCase();
          return nama.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ---- HEADER ----
            Container(
              width: double.infinity,
              color: const Color(0xff2E9900),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.store, color: Colors.green),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "MbahMeth",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Portal Admin",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              "Kelola Pengguna",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            // ---- SEARCH ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: "Cari nama / email",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ---- TAB ----
            Row(
              children: [
                _tabButton("Semua", 0),
                _tabButton("Admin", 1),
                _tabButton("Pelanggan", 2),
              ],
            ),
            Row(
              children: [
                _tabLine(0),
                _tabLine(1),
                _tabLine(2),
              ],
            ),

            const SizedBox(height: 5),

            // ---- KONTEN ----
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xff2E9900)),
                    )
                  : errorMsg.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 10),
                              Text(
                                errorMsg,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: fetchUsers,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Coba Lagi"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2E9900),
                                  foregroundColor: Colors.white,
                                ),
                              )
                            ],
                          ),
                        )
                      : filteredUsers.isEmpty
                          ? const Center(
                              child: Text(
                                "Tidak ada data pengguna",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : RefreshIndicator(
                              color: const Color(0xff2E9900),
                              onRefresh: fetchUsers,
                              child: ListView.builder(
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = filteredUsers[index];
                                  return UserTile(
                                    name: user["nama_lengkap"] ?? "-",
                                    email: user["email"] ?? "-",
                                    role: user["role"] ?? "-",
                                    roleColor: _roleColor(user["role"] ?? ""),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final active = selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTab = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        color: selectedTab == index ? Colors.green : Colors.transparent,
      ),
    );
  }
}

// ---- USER TILE ----
class UserTile extends StatelessWidget {
  final String name, email, role;
  final Color roleColor;

  const UserTile({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundColor: roleColor.withOpacity(0.2),
        child: Icon(
          role.toLowerCase() == "admin" ? Icons.admin_panel_settings : Icons.person,
          color: roleColor,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      subtitle: Text(email, style: const TextStyle(fontSize: 11)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: roleColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          role.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: roleColor,
          ),
        ),
      ),
    );
  }
}
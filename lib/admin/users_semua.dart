import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_mbahmeth/services/api_service.dart';

class UsersSemua extends StatefulWidget {

  final bool isEmbedded;

  const UsersSemua({super.key, this.isEmbedded = false});

  @override
  State<UsersSemua> createState() => _UsersSemuaState();
}

class _UsersSemuaState extends State<UsersSemua> {
  static const _primaryGreen     = Color(0xFF2E9900);
  static const _primaryGreenDark = Color(0xFF1F6B00);
  static const _backgroundLight  = Color(0xFFF4FAF2);
  static const _backgroundWhite  = Color(0xFFFFFFFF);
  static const _textDark         = Color(0xFF1A2E1A);
  static const _textLight        = Color(0xFF8A9E8A);
  static const _inputBorder      = Color(0xFFDFEFDF);
  static const _textHint         = Color(0xFFB0C4B0);

  int selectedTab = 0;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredBySearch = [];
  bool isLoading = true;
  String errorMsg = "";
  String searchQuery = "";

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case "admin":
        return const Color(0xFF2E9900);
      case "pelanggan":
        return const Color(0xFF3DB800);
      default:
        return _textLight;
    }
  }

  Color _roleBgColor(String role) {
    switch (role.toLowerCase()) {
      case "admin":
        return const Color(0xFFE8F5E2);
      case "pelanggan":
        return const Color(0xFFF4FAF2);
      default:
        return const Color(0xFFF4FAF2);
    }
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMsg = "";
    });

    try {
      final json = await ApiService().getAllUsers();

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
    } catch (e) {
      setState(() {
        errorMsg = "Terjadi kesalahan sistem.";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  List<Map<String, dynamic>> get filteredUsers {
    List<Map<String, dynamic>> result = filteredBySearch;
    if (selectedTab == 1) {
      result = result.where((e) => e["role"].toLowerCase() == "admin").toList();
    } else if (selectedTab == 2) {
      result = result.where((e) => e["role"].toLowerCase() == "pelanggan").toList();
    }
    return result;
  }

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // icon baterai/jam jadi putih
      child: Scaffold(
      backgroundColor: _backgroundLight,
      body: Column(
        children: [
            // ── Header dengan gradient (tembus sampai status bar) ──────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryGreenDark, _primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                4,
                MediaQuery.of(context).padding.top + 10,
                16,
                14,
              ),
              child: Row(
                children: [
                  // FIX: Tombol back HANYA tampil ketika halaman di-push sebagai
                  //      route terpisah (isEmbedded == false).
                  if (!widget.isEmbedded)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  if (widget.isEmbedded) const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/x2.png',
                    height: 38,
                    errorBuilder: (c, e, s) => Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.eco_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  // Tombol refresh di kanan
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: fetchUsers,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E9900).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people_rounded,
                        color: _primaryGreen, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Kelola Pengguna",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Search ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: onSearch,
                style: const TextStyle(color: _textDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Cari nama / email",
                  hintStyle: const TextStyle(color: _textHint),
                  prefixIcon: const Icon(Icons.search, color: _textLight),
                  filled: true,
                  fillColor: _backgroundWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: _inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: _inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: _primaryGreen, width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Tab ───────────────────────────────────────────────────
            Container(
              color: _backgroundWhite,
              child: Row(
                children: [
                  _tabButton("Semua", 0),
                  _tabButton("Admin", 1),
                  _tabButton("Pelanggan", 2),
                ],
              ),
            ),
            Container(
              color: _backgroundWhite,
              child: Row(
                children: [
                  _tabLine(0),
                  _tabLine(1),
                  _tabLine(2),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ── Konten ────────────────────────────────────────────────
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primaryGreen),
                    )
                  : errorMsg.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFEBEB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.wifi_off,
                                    size: 36, color: Color(0xFFD32F2F)),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                errorMsg,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: _textLight),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: fetchUsers,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Coba Lagi"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : filteredUsers.isEmpty
                          ? const Center(
                              child: Text(
                                "Tidak ada data pengguna",
                                style: TextStyle(color: _textLight),
                              ),
                            )
                          : RefreshIndicator(
                              color: _primaryGreen,
                              onRefresh: fetchUsers,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = filteredUsers[index];
                                  return _UserTile(
                                    name: user["nama_lengkap"] ?? "-",
                                    email: user["email"] ?? "-",
                                    role: user["role"] ?? "-",
                                    roleColor:
                                        _roleColor(user["role"] ?? ""),
                                    roleBgColor:
                                        _roleBgColor(user["role"] ?? ""),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ), // Scaffold
    ); // AnnotatedRegion
  }

  Widget _tabButton(String text, int index) {
    final active = selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTab = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? _primaryGreen : _textLight,
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
        color: selectedTab == index ? _primaryGreen : Colors.transparent,
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final String name, email, role;
  final Color roleColor;
  final Color roleBgColor;

  static const _textDark   = Color(0xFF1A2E1A);
  static const _textLight  = Color(0xFF8A9E8A);
  static const _cardBorder = Color(0xFFEEF5EE);

  const _UserTile({
    required this.name,
    required this.email,
    required this.role,
    required this.roleColor,
    required this.roleBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E9900).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: roleBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              role.toLowerCase() == "admin"
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_rounded,
              color: roleColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textDark),
                ),
                const SizedBox(height: 2),
                Text(email,
                    style:
                        const TextStyle(fontSize: 12, color: _textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: roleBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class UsersSemua extends StatefulWidget {
  const UsersSemua({super.key});

  @override
  State<UsersSemua> createState() => _UsersSemuaState();
}

class _UsersSemuaState extends State<UsersSemua> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> users = [
    {
      "name": "Eko Prasetyo",
      "email": "eko.pra@gmail.id",
      "role": "Pelanggan",
      "time": "Sekarang",
      "color": Colors.green,
    },
    {
      "name": "Ahmad Fauzi",
      "email": "ahmad@gmail.com",
      "role": "Pelanggan",
      "time": "2 jam lalu",
      "color": Colors.green,
    },
    {
      "name": "Siti Aminah",
      "email": "siti@gmail.com",
      "role": "Admin",
      "time": "Aktif",
      "color": Colors.blue,
    },
    {
      "name": "Budi Santoso",
      "email": "budi@gmail.com",
      "role": "Pelanggan",
      "time": "1 hari lalu",
      "color": Colors.green,
    },
  ];

  List<Map<String, dynamic>> get filteredUsers {
    if (selectedTab == 1) {
      return users.where((e) => e["role"] == "Admin").toList();
    } else if (selectedTab == 2) {
      return users.where((e) => e["role"] == "Pelanggan").toList();
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
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
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              "Kelola Pengguna",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
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

            // TAB
            Row(
              children: [
                tabButton("Semua", 0),
                tabButton("Admin", 1),
                tabButton("Pelanggan", 2),
              ],
            ),
            Row(
              children: [
                tabLine(0),
                tabLine(1),
                tabLine(2),
              ],
            ),

            const SizedBox(height: 5),

            // LIST USER
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return UserTile(
                    name: user["name"],
                    email: user["email"],
                    role: user["role"],
                    roleColor: user["color"],
                    time: user["time"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB BUTTON
  Widget tabButton(String text, int index) {
    final active = selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
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

  // TAB LINE
  Widget tabLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        color: selectedTab == index ? Colors.green : Colors.transparent,
      ),
    );
  }
}

// USER TILE
class UserTile extends StatelessWidget {
  final String name, email, role, time;
  final Color roleColor;

  const UserTile({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.roleColor,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(email, style: const TextStyle(fontSize: 11)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}
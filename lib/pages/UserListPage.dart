import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AddUserPage.dart';
import 'EditUserPage.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List users = [];
  List filteredUsers = [];

  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://localhost/flutter_api/user/get_user.php",
        ),
      );

      final result = jsonDecode(response.body);

      setState(() {
        users = result["data"] ?? [];
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost/flutter_api/user/delete_user.php",
        ),
        body: {
          "id": id,
        },
      );

      final result = jsonDecode(response.body);

      if (result["status"] == true) {
        getUsers();
      }
    } catch (e) {
      print(e);
    }
  }

  void searchUser(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        filteredUsers = users;
      });
      return;
    }

    final results = users.where((user) {
      final username = user["username"].toString().toLowerCase();

      final email = user["email"].toString().toLowerCase();

      return username.contains(
            keyword.toLowerCase(),
          ) ||
          email.contains(
            keyword.toLowerCase(),
          );
    }).toList();

    setState(() {
      filteredUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar User"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddUserPage(),
            ),
          );

          getUsers();
        },
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchUser,
                    decoration: const InputDecoration(
                      hintText: "Cari username atau email",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            filteredUsers[index]["username"],
                          ),
                          subtitle: Text(
                            filteredUsers[index]["email"],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditUserPage(
                                        id: filteredUsers[index]["id"],
                                        username: filteredUsers[index]
                                            ["username"],
                                        email: filteredUsers[index]["email"],
                                      ),
                                    ),
                                  ).then((value) {
                                    getUsers();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        "Konfirmasi",
                                      ),
                                      content: const Text(
                                        "Yakin ingin menghapus user ini?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Batal",
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            await deleteUser(
                                              filteredUsers[index]["id"],
                                            );
                                          },
                                          child: const Text(
                                            "Hapus",
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditUserPage extends StatefulWidget {
  final String id;
  final String username;
  final String email;

  const EditUserPage({
    super.key,
    required this.id,
    required this.username,
    required this.email,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: widget.username);

    emailController = TextEditingController(text: widget.email);
  }

  Future<void> updateUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost/flutter_api/user/update_user.php",
        ),
        body: {
          "id": widget.id,
          "username": usernameController.text,
          "email": emailController.text,
        },
      );

      final result = jsonDecode(response.body);

      if (result["status"] == true) {
        if (!mounted) return;

        Navigator.pop(
          context,
          "User berhasil diupdate",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"],
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateUser,
                child: const Text(
                  "Simpan Perubahan",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadFotoPage extends StatefulWidget {
  final dynamic userId;

  const UploadFotoPage({
    super.key,
    required this.userId,
  });

  @override
  State<UploadFotoPage> createState() => _UploadFotoPageState();
}

class _UploadFotoPageState extends State<UploadFotoPage> {
  final ImagePicker picker = ImagePicker();

  XFile? selectedFile;
  Uint8List? imageBytes;

  bool isLoading = false;

  Future<void> pilihGaleri() async {
    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();

        setState(() {
          selectedFile = file;
          imageBytes = bytes;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto berhasil dipilih"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> uploadFoto() async {
    if (selectedFile == null || imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Silakan pilih gambar terlebih dahulu",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse(
          "http://localhost/FLUTTER_API/user/upload_image.php",
        ),
      );

      request.fields["id"] = widget.userId.toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          imageBytes!,
          filename: selectedFile!.name,
        ),
      );

      var response = await request.send();

      var result = await http.Response.fromStream(
        response,
      );

      var data = jsonDecode(result.body);

      if (data["status"] == "success") {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"],
            ),
          ),
        );

        Navigator.pop(
          context,
          true,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Upload gagal: $e",
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Foto",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage:
                  imageBytes != null ? MemoryImage(imageBytes!) : null,
              child: imageBytes == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                    )
                  : null,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: pilihGaleri,
              icon: const Icon(
                Icons.photo,
              ),
              label: const Text(
                "Galeri",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: isLoading ? null : uploadFoto,
              child: const Text(
                "Simpan ke Server",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

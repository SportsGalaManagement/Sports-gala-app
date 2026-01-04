import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class GalleryScreen extends StatefulWidget {
  final bool isAdmin;
  const GalleryScreen({super.key, required this.isAdmin});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isUploading = false;
  final String _apiUrl = "https://codevia.codes/sports_api/upload.php";

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Size thora kam kiya taake fast upload ho
    );

    if (image == null) return;
    setState(() => _isUploading = true);

    try {
      var byteData = await image.readAsBytes();
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        byteData,
        filename: image.name,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // Console mein check karne ke liye (Debug)
      print("Response: $responseData");

      var jsonResponse = json.decode(responseData);

      if (jsonResponse['status'] == 'success') {
        await FirebaseFirestore.instance.collection('gallery').add({
          'imageUrl': jsonResponse['url'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image Uploaded Successfully! ✅")),
          );
        }
      } else {
        throw jsonResponse['message'] ?? "Upload failed";
      }
    } catch (e) {
      print("Error detail: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e ❌")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D2671);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Gala Gallery", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUploadImage,
        backgroundColor: primaryBlue,
        label: Text(_isUploading ? "Uploading..." : "Add Photo", style: const TextStyle(color: Colors.white)),
        icon: _isUploading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.add_a_photo, color: Colors.white),
      )
          : null,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('gallery').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No photos yet."));

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      doc['imageUrl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      // Loading indicator for network images
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                  if (widget.isAdmin)
                    Positioned(
                      right: 5, top: 5,
                      child: IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.red, radius: 14, child: Icon(Icons.delete, size: 16, color: Colors.white)),
                        onPressed: () => doc.reference.delete(),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

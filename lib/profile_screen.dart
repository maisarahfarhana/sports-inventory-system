import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedImage(); // Muat gambar setiap kali skrin dibuka
  }

  // --- 1. MUAT GAMBAR DARI STORAN KEKAL (Task 2) ---
  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan username sebagai prefix kunci
    String userKey = 'profile_path_${widget.userData['username']}';
    final String? imagePath = prefs.getString(userKey);

    if (imagePath != null && imagePath.isNotEmpty) {
      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        setState(() => _image = imageFile);
      }
    }
  }

  // --- 2. AMBIL GAMBAR & SIMPAN PATH (Task 3) ---
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));

      final prefs = await SharedPreferences.getInstance();
      // KUNCI MESTI ADA USERNAME!
      String userKey = 'profile_path_${widget.userData['username']}';
      await prefs.setString(userKey, pickedFile.path);
    }
  }

  // --- 3. MENU PEMILIH (Task 4) ---
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF87CEFA)),
                title: const Text('Photo Library'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF87CEFA)),
                title: const Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isStaff = widget.userData['role'] == 'Staff';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87CEFA), // Biru KPM
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context, true), // Hantar 'true' untuk refresh Drawer
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.person, size: 65, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showPicker(context),
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFF87CEFA),
                        radius: 22,
                        child: Icon(Icons.camera_alt, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _infoCard("Username", widget.userData['username'] ?? "Syu", Icons.person_outline),
            _infoCard("User Role", widget.userData['role'] ?? "N/A", Icons.badge_outlined),
            if (isStaff) ...[
              _infoCard("Staff Email", widget.userData['email'] ?? "N/A", Icons.email_outlined),
              _infoCard("Staff ID", widget.userData['staffId'] ?? "N/A", Icons.card_membership_outlined),
            ] else ...[
              _infoCard("Student ID", widget.userData['studentId'] ?? "N/A", Icons.numbers),
              _infoCard("Course", widget.userData['course'] ?? "N/A", Icons.school_outlined),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF87CEFA)),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}
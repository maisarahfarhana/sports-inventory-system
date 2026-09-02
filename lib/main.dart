import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';


import 'sports_inventory_screen.dart';
import 'database_helper.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';
import 'staff_all_bookings_screen.dart';
import 'weather_screen.dart';

const Color lightBlue = Color(0xFF87CEFA);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TAMBAHKAN BLOK INI UNTUK PELAYAR WEB:
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: lightBlue,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      home: const LoginPage(),
    );
  }
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController(); // Digunakan untuk Username atau Staff ID
  final _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Role default adalah Student
  String _selectedRole = 'Student';

  void _login() async {
    String inputId = _idController.text.trim();
    String password = _passwordController.text.trim();

    if (inputId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // --- LOGIK BARU: Cari dalam database berdasarkan ID/Username ---
    bool isValid = await _dbHelper.loginUser(inputId, password);

    if (isValid) {
      // Ambil data user guna ID yang dimasukkan tadi
      Map<String, dynamic>? data = await _dbHelper.getUser(inputId);

      if (mounted && data != null) {
        // Pastikan role yang dipilih (Student/Staff) sama dengan role dalam database
        if (data['role'] == _selectedRole) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen(userData: data))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('This ID is registered as ${data['role']}, not $_selectedRole')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid ID or Password. Please check again.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.sports_basketball, size: 80, color: lightBlue),
              const SizedBox(height: 10),
              const Text('KPM SPORT LOGIN',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 30),

              // --- PILIHAN ROLE (Task 4: GUI) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _roleButton('Student'),
                  const SizedBox(width: 10),
                  _roleButton('Staff'),
                ],
              ),
              const SizedBox(height: 25),

              // --- INPUT FIELD (Dinamik mengikut Role) ---
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  prefixIcon: Icon(_selectedRole == 'Staff' ? Icons.badge : Icons.person),
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                  )
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _login,
                  child: const Text('LOGIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())),
                child: const Text('Don\'t have an account? Create New Account', style: TextStyle(color: Colors.blueGrey)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget Button untuk tukar Role
  Widget _roleButton(String role) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? lightBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? lightBlue : Colors.grey),
        ),
        child: Text(
          role,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
// --- SIGNUP PAGE ---
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  final _courseController = TextEditingController();

  String _selectedRole = 'Student';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _register() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty || _idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila penuhkan Username, Password dan ID anda!')),
      );
      return;
    }

    try {
      Map<String, dynamic> userData = {
        'username': _userController.text.trim(),
        'password': _passController.text.trim(),
        'role': _selectedRole,
        'email': _selectedRole == 'Staff' ? _emailController.text.trim() : '',
        'staffId': _selectedRole == 'Staff' ? _idController.text.trim() : '',
        'studentId': _selectedRole == 'Student' ? _idController.text.trim() : '',
        'course': _selectedRole == 'Student' ? _courseController.text.trim() : '',
      };

      await _dbHelper.registerUser(userData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran Berjaya! Sila Log Masuk.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('Sign Up',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: lightBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.person_add_alt_1, size: 70, color: lightBlue),
            const SizedBox(height: 20),

            const Text("Select Your Role", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roleChoice('Student', Icons.school),
                const SizedBox(width: 15),
                _roleChoice('Staff', Icons.badge),
              ],
            ),

            const SizedBox(height: 30),

            _buildTextField(_userController, 'Username', Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(_passController, 'Password', Icons.lock_outline, isObscure: true),
            const SizedBox(height: 16),

            if (_selectedRole == 'Staff') ...[
              _buildTextField(_idController, 'Staff ID', Icons.vpn_key_outlined),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Staff Email', Icons.email_outlined),
            ],

            if (_selectedRole == 'Student') ...[
              _buildTextField(_idController, 'Student ID', Icons.numbers),
              const SizedBox(height: 16),
              _buildTextField(_courseController, 'Course Name', Icons.book_outlined),
            ],

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                onPressed: _register,
                child: const Text('REGISTER NOW',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChoice(String role, IconData icon) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? lightBlue : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.black : Colors.grey),
            const SizedBox(width: 8),
            Text(role, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: lightBlue),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MainScreen({super.key, required this.userData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _drawerImage;

  @override
  void initState() {
    super.initState();
    _loadDrawerImage();
  }

  Future<void> _loadDrawerImage() async {
    final prefs = await SharedPreferences.getInstance();
    String userKey = 'profile_path_${widget.userData['username']}';
    final String? path = prefs.getString(userKey);

    if (path != null && path.isNotEmpty) {
      setState(() {
        _drawerImage = File(path);
      });
    } else {
      setState(() {
        _drawerImage = null;
      });
    }
  }

  Future<void> _launchWhatsApp() async {
    final String phoneNumber = "601137458216";
    final String message = "Hi Admin, i am ${widget.userData['username']} (${widget.userData['role']}). i want to know regarding to sports equipment.";
    final Uri url = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KPM BERANANG',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.userData['role'] == 'Student')
            IconButton(
              icon: const Icon(Icons.assignment_outlined, color: Colors.black),
              tooltip: 'My Bookings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyBookingsScreen(username: widget.userData['username']),
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: lightBlue),
              accountName: Text(
                  widget.userData['username'] ?? "User",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
              ),
              accountEmail: Text(
                  widget.userData['role'] == 'Staff'
                      ? (widget.userData['email'] ?? "staff@kpmberanang.edu.my")
                      : widget.userData['role'],
                  style: const TextStyle(color: Colors.black54)
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _drawerImage != null ? FileImage(_drawerImage!) : null,
                child: _drawerImage == null
                    ? const Icon(Icons.person, size: 40, color: lightBlue)
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userData: widget.userData),
                  ),
                ).then((_) => _loadDrawerImage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
              title: const Text('Checking Weather'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherScreen()),
                );
              },
            ),
            if (widget.userData['role'] == 'Staff')
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('All Bookings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StaffAllBookingsScreen()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('WhatsApp Admin'),
              subtitle: const Text('Direct Support'),
              onTap: () {
                Navigator.pop(context);
                _launchWhatsApp();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const SizedBox(height: 10),
          _HeroBanner(
            onStart: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SportsInventoryScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ScoreStrip(),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text(
                  'Latest Updates',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
              children: const [
                _NewsCard(
                  imagePath: 'assets/images/footballs.jpg',
                  title: 'Equipment Booking Tips',
                  subtitle: 'Book early to avoid clashes.',
                ),
                _NewsCard(
                  imagePath: 'assets/images/basketballs.jpg',
                  title: 'New Equipment Added',
                  subtitle: 'Check out latest gear!',
                ),
                _NewsCard(
                  imagePath: 'assets/images/volleyball.jpg',
                  title: 'Return Reminder',
                  subtitle: 'Return items on time.',
                ),
                _NewsCard(
                  imagePath: 'assets/images/badminton.jpg',
                  title: 'Stay Safe',
                  subtitle: 'Use equipment properly.',
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SportsInventoryScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Booking'),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onStart;
  const _HeroBanner({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                'assets/images/sportss.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Sport Inventory Management System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Book equipment easily & track bookings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightBlue,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onStart,
                      child: const Text('Start Booking'),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final isActive = i == 1;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 14 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? lightBlue : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ScoreStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const _NewsCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
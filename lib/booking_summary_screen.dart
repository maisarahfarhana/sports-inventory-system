
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sports_inventory_screen.dart';
import 'database_helper.dart'; // TMBH INI

class BookingSummaryScreen extends StatefulWidget {
  final String sport;
  final String equipment;
  final String name;
  final String className;
  final String date;
  final String duration;

  const BookingSummaryScreen({
    super.key,
    required this.sport,
    required this.equipment,
    required this.name,
    required this.className,
    required this.date,
    required this.duration,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  static const Color lightPink = Color(0xFF50C1FB);
  bool _showDetails = true;
  @override
  void initState() {
    super.initState();
    _saveToDatabase();
  }

  void _saveToDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.addBooking({
      'username': widget.name,
      'sport': widget.sport,
      'equipment_name': widget.equipment,
      'student_name': widget.name,
      'class_name': widget.className,
      'date': widget.date,
      'duration': widget.duration,
      'status': 'Booked',
    });
  }
  String get _allText =>
      'Sport: ${widget.sport}\n'
          'Equipment: ${widget.equipment}\n'
          'Name: ${widget.name}\n'
          'Class: ${widget.className}\n'
          'Date: ${widget.date}\n'
          'Duration: ${widget.duration}';

  Future<void> _copyAll() async {
    await Clipboard.setData(ClipboardData(text: _allText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: lightPink,
        content: Text('Copied all booking details ✅'),
      ),
    );
  }

  Future<void> _copyField(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: lightPink,
        content: Text('$label copied ✅'),
      ),
    );
  }

  void _showInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('How to use',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('• Tap any row to copy its value'),
            Text('• Use "Copy All" to copy full booking'),
            Text('• Hide/Show to toggle details'),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _copyField(label, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Icon(icon, color: lightPink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(value),
                ],
              ),
            ),
            const Icon(Icons.copy, size: 18, color: lightPink),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
        backgroundColor: lightPink,
        actions: [
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
          IconButton(
            onPressed: _copyAll,
            icon: const Icon(Icons.copy_all, color: Colors.white),
          ),
        ],
// Remove the Back button (leading) from the app bar
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
// Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: lightPink.withOpacity(0.08),
                border: Border.all(color: lightPink),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_turned_in, color: lightPink),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Your Booking Form',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showDetails = !_showDetails),
                    icon: Icon(
                      _showDetails
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: lightPink,
                    ),
                    label: Text(
                      _showDetails ? 'Hide' : 'Show',
                      style: const TextStyle(color: lightPink),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

// Details
            Expanded(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: _showDetails
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: ListView(
                  children: [
                    _row(
                        icon: Icons.sports,
                        label: 'Sport',
                        value: widget.sport),
                    const SizedBox(height: 10),
                    _row(
                        icon: Icons.inventory_2,
                        label: 'Equipment',
                        value: widget.equipment),
                    const SizedBox(height: 10),
                    _row(
                        icon: Icons.person,
                        label: 'Name',
                        value: widget.name),
                    const SizedBox(height: 10),
                    _row(
                        icon: Icons.school,
                        label: 'Class',
                        value: widget.className),
                    const SizedBox(height: 10),
                    _row(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: widget.date),
                    const SizedBox(height: 10),
                    _row(
                        icon: Icons.timer,
                        label: 'Duration',
                        value: widget.duration),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightPink,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _copyAll,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy All Details'),
                      ),
                    ),
                  ],
                ),
                secondChild: const Center(
                  child: Text('Details hidden. Tap "Show" to view again.'),
                ),
              ),
            ),
          ],
        ),
      ),

// Bottom navigation bar with custom icons and color
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black, // Color for selected items
        unselectedItemColor: Colors.black, // Color for unselected items
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), // Photo-like icon for "Home"
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports), // Camera-like icon for "Booking"
            label: 'Booking',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
// Navigate to Home
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
// Navigate to New Booking
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SportsInventoryScreen()),
            );
          }
        },
      ),
    );
  }
}
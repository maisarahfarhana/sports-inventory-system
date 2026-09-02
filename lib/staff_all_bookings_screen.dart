import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StaffAllBookingsScreen extends StatefulWidget {
  const StaffAllBookingsScreen({super.key});

  @override
  State<StaffAllBookingsScreen> createState() => _StaffAllBookingsScreenState();
}

class _StaffAllBookingsScreenState extends State<StaffAllBookingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Refresh senarai dengan memanggil setState
  void _refreshList() {
    setState(() {});
  }

  // --- FUNGSI DELETE (D) ---
  void _deleteBooking(int id) async {
    await _dbHelper.deleteBooking(id);
    _refreshList();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking removed successfully')),
    );
  }

  // --- FUNGSI UPDATE (U) ---
  void _showEditDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['student_name']);
    final equipController = TextEditingController(text: item['equipment_name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Booking"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Student Name")),
            TextField(controller: equipController, decoration: const InputDecoration(labelText: "Equipment")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.updateBooking(item['id'], {
                'student_name': nameController.text,
                'equipment_name': equipController.text,
              });
              Navigator.pop(context);
              _refreshList();
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI PDF (Innovation Feature) ---
  Future<void> _generatePDF(Map<String, dynamic> item) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            children: [
              pw.Text("KPM BERANANG SPORTS SYSTEM", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Booking Confirmation", style: pw.TextStyle(fontSize: 18)),
              pw.Divider(),
              pw.Text("Student: ${item['student_name']}"),
              pw.Text("Equipment: ${item['equipment_name']}"),
              pw.Text("Sport: ${item['sport']}"),
              pw.Text("Date: ${item['date']}"),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'All Student Bookings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF87CEFA), // Biru KPM Konsisten
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final item = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(backgroundColor: Color(0xFF87CEFA), child: Icon(Icons.person, color: Colors.white)),
                  title: Text("${item['student_name']} - ${item['equipment_name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Date: ${item['date']} | Sport: ${item['sport']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol PDF
                      IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.orange), onPressed: () => _generatePDF(item)),
                      // Tombol Edit
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(item)),
                      // Tombol Delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _showDeleteConfirmation(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // --- FUNGSI ADD (C) ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF87CEFA),
        onPressed: () {
          // Navigasi ke skrin tambah tempahan anda
        },
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Booking"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _deleteBooking(id);
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
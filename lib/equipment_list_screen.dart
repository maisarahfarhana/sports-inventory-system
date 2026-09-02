import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'database_helper.dart'; // TAMBAH INI

class EquipmentListScreen extends StatelessWidget {
  final String sport;
  const EquipmentListScreen({super.key, required this.sport});

  static const Color lightPink = Color(0xFF50C1FB);

  // Fungsi asal anda (Jangan tukar)
  List<String> _itemsBySport(String sport) {
    switch (sport) {
      case 'Football':
        return ['Football Ball', 'Football Goal', 'Cones', 'Whistle', 'Jersey/Bibs', 'Stopwatch'];
      case 'Basketball':
        return ['Basketball', 'Basketball Hoop', 'Ball Pump', 'Cones', 'Jersey/Bibs', 'Stopwatch'];
      case 'Volleyball':
        return ['Volleyball', 'Volleyball Net', 'Antenna Poles', 'Knee Pads', 'Whistle', 'Scoreboard'];
      case 'Badminton':
        return ['Badminton Racket', 'Shuttlecock', 'Badminton Net', 'Grip Tape', 'Umpire Chair', 'Scoreboard'];
      case 'Netball':
        return ['Netball', 'Netball Goal', 'Bibs', 'Cones', 'Whistle', 'Stopwatch'];
      case 'Handball':
        return ['Handball Ball', 'Handball Goal', 'Cones', 'Whistle', 'Jersey/Bibs', 'Stopwatch'];
      default:
        return ['Ball', 'Goal/Net', 'Cones', 'Whistle', 'Bibs', 'Stopwatch'];
    }
  }

  // --- TAMBAH FUNGSI BARU DI SINI UNTUK AMBIL DATA DARI DB ---
  Future<List<String>> _getCombinedItems() async {
    List<String> staticItems = _itemsBySport(sport);
    try {
      final dbData = await DatabaseHelper().getAllEquipment();
      // Filter alatan mengikut sukan dan ambil namanya sahaja
      List<String> newItems = dbData
          .where((row) => row['sport_type'] == sport)
          .map((row) => row['equipment_name'] as String)
          .toList();

      return [...staticItems, ...newItems]; // Gabungkan senarai lama + baru
    } catch (e) {
      return staticItems; // Jika error, return senarai asal sahaja
    }
  }

  @override
  Widget build(BuildContext context) {
    // TUKAR 'final items = _itemsBySport(sport);' KEPADA FutureBuilder
    return Scaffold(
      appBar: AppBar(
        title: Text('$sport Equipment'),
        backgroundColor: lightPink,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: FutureBuilder<List<String>>(
        future: _getCombinedItems(), // Panggil fungsi gabungan tadi
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? _itemsBySport(sport);

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(color: lightPink.withOpacity(0.6)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          sport: sport,
                          equipment: item,
                        ),
                      ),
                    );
                  },
                  child: Text(item),
                );
              },
            ),
          );
        },
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: lightPink.withOpacity(0.25),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Select one equipment to continue booking',
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
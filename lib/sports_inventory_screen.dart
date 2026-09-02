
import 'package:flutter/material.dart';
import 'equipment_list_screen.dart';


class SportsInventoryScreen extends StatelessWidget {
  final List<Category> categories = [
    Category('Football', 'assets/images/footballs.jpg'),
    Category('Basketball', 'assets/images/basketballs.jpg'),
    Category('Volleyball', 'assets/images/volleyball.jpg'),
    Category('Badminton', 'assets/images/badminton.jpg'),
    Category('Netball', 'assets/images/netballs.jpg'),
    Category('Handball', 'assets/images/handballs.jpg'),
  ];
  static const Color lightPink = Color(0xFF50C1FB);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Equipment Inventory'),
        backgroundColor: lightPink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('What sport are you interested in?', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EquipmentListScreen(sport: category.name),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: AssetImage(category.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2.0, 2.0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final String name;
  final String imagePath;
  Category(this.name, this.imagePath);
}
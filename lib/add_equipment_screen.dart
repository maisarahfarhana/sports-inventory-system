import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedSport = 'Football';

  void _saveEquipment() async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    await DatabaseHelper().addEquipment({
      'equipment_name': _nameController.text,
      'sport_type': _selectedSport,
      'quantity': int.parse(_quantityController.text),
      'image_path': '', // Boleh ditambah kemudian jika mahu fungsi gambar
    });

    Navigator.pop(context); // Kembali selepas simpan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New equipment added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Equipment'), backgroundColor: Colors.lightBlue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Equipment Name')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedSport,
              items: ['Football', 'Badminton', 'Netball', 'Basketball','Valleyball', 'Handball'].map((s) =>
                  DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSport = val!),
              decoration: const InputDecoration(labelText: 'Sport Category'),
            ),
            const SizedBox(height: 10),
            TextField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEquipment,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              child: const Text('Save Equipment'),
            )
          ],
        ),
      ),
    );
  }
}
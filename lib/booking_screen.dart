import 'package:flutter/material.dart';
import 'booking_summary_screen.dart';

class BookingScreen extends StatefulWidget {
  final String sport;
  final String equipment;

  const BookingScreen({
    super.key,
    required this.sport,
    required this.equipment,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
// 🌸 Light pink palette
  static const Color lightPink = Color(0xFF50C1FB);
  static const Color pinkAccent = Color(0xFF63D0FF);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _duration = '1 Hour';
  bool _agree = false;

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: pinkAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms before submit.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Sport: ${widget.sport}'),
              Text('Equipment: ${widget.equipment}'),
              Text('Name: ${_nameController.text}'),
              Text('Class: ${_classController.text}'),
              Text('Date: ${_dateController.text}'),
              Text('Duration: $_duration'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkAccent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    final goView = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(
                        title: const Text('Booking Submitted ✅'),
                        content: const Text(
                            'Do you want to view your booking form?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('NO'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pinkAccent,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('YES'),
                          ),
                        ],
                      ),
                    );

                    if (goView == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingSummaryScreen(
                            sport: widget.sport,
                            equipment: widget.equipment,
                            name: _nameController.text,
                            className: _classController.text,
                            date: _dateController.text,
                            duration: _duration,
                          ),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: pinkAccent),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: pinkAccent, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: lightPink.withOpacity(0.6)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.sport}'),
        backgroundColor: lightPink,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: lightPink.withOpacity(0.25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Equipment',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.equipment,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(
                    'Sport: ${widget.sport}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _input('Name', Icons.person),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _classController,
                    decoration: _input('Class', Icons.school),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Class is required'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: _input('Booking Date', Icons.calendar_today)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range),
                        color: pinkAccent,
                        onPressed: _pickDate,
                      ),
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Date is required'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _duration,
                    decoration: _input('Duration', Icons.timer),
                    items: const [
                      DropdownMenuItem(
                          value: '1 Hour', child: Text('1 Hour')),
                      DropdownMenuItem(
                          value: '2 Hours', child: Text('2 Hours')),
                      DropdownMenuItem(
                          value: '3 Hours', child: Text('3 Hours')),
                    ],
                    onChanged: (val) =>
                        setState(() => _duration = val ?? '1 Hour'),
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    activeColor: pinkAccent,
                    value: _agree,
                    onChanged: (v) => setState(() => _agree = v),
                    title: const Text('Agree to booking terms'),
                    subtitle: const Text(
                        'Equipment must be returned in good condition.'),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pinkAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: _submit,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Submit Booking'),
                    ),
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
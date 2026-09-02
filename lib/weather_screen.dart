import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const Color lightBlue = Color(0xFF87CEFA);
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Use the same lightBlue from your main.dart for consistency
  final Color lightBlue = const Color(0xFF87CEFA);

  double _tempValue = 0.0;
  String _tempText = "--";
  String _suitability = "Checking...";
  String _advice = "Fetching live data...";
  IconData _statusIcon = Icons.cloud;
  Color _statusColor = Colors.blue;
  bool _isLoading = true;

  Future<void> fetchWeather() async {
    setState(() => _isLoading = true);
    try {
      // API 1: Open-Meteo for Weather Data
      final response = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=2.87&longitude=101.87&current_weather=true'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double temp = data['current_weather']['temperature'];

        setState(() {
          _tempValue = temp;
          _tempText = "$temp°C";
          _updateSuitability(temp);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _tempText = "Offline";
        _isLoading = false;
      });
    }
  }

  void _updateSuitability(double temp) {
    if (temp > 33) {
      _suitability = "NOT RECOMMENDED";
      _advice = "It's too hot for outdoor sports. Risk of heat exhaustion.";
      _statusColor = Colors.redAccent;
      _statusIcon = Icons.warning_amber_rounded;
    } else if (temp >= 24) {
      _suitability = "SUITABLE FOR SPORTS";
      _advice = "Great weather for Sports! Remember to stay hydrated.";
      _statusColor = Colors.green;
      _statusIcon = Icons.wb_sunny_rounded;
    } else {
      _suitability = "PERFECT CONDITIONS";
      _advice = "Ideal cool temperature for high-intensity training.";
      _statusColor = Colors.green;
      _statusIcon = Icons.check_circle_outline;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      // KEMAS KINI DI SINI: AppBar dengan warna biru penuh
      appBar: AppBar(
        backgroundColor: lightBlue, // Menggunakan warna 0xFF87CEFA
        elevation: 0, // Menghilangkan bayang untuk nampak rata
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Field Conditions',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: lightBlue))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Main Temperature Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text("KPM BERANANG", style: TextStyle(letterSpacing: 2, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Icon(_statusIcon, size: 80, color: _statusColor),
                  Text(
                    _tempText,
                    style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Suitability Analysis Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _suitability,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _statusColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _advice,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Activity Recommendations Grid
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Sport Recommendations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),

            _buildActivityRow("Football / Track", _tempValue < 32),
            const SizedBox(height: 10),
            _buildActivityRow("Outdoor Basketball", _tempValue < 30),
            const SizedBox(height: 10),
            _buildActivityRow(" Outdoor Netball ", _tempValue < 32),
            const SizedBox(height: 10),
            _buildActivityRow("Outdoor Handball", _tempValue < 30),
            const SizedBox(height: 10),
            _buildActivityRow("Indoor Valleyball", _tempValue < 36),
            const SizedBox(height: 10),
            _buildActivityRow("Indoor Badminton", true),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: fetchWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightBlue,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("REFRESH LIVE DATA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String sport, bool isGood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(sport, style: const TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isGood ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isGood ? "Recommended" : "Not Ideal",
              style: TextStyle(color: isGood ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
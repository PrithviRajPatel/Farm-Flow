import 'package:flutter/material.dart';

class IsroWeatherPage extends StatelessWidget {
  const IsroWeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISRO Weather'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentWeatherCard(),
            const SizedBox(height: 20),
            _build7DayForecast(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Current Weather', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Icon(Icons.wb_sunny, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text('28°C', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const Text('Clear Sky', style: TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(Icons.water_drop, 'Humidity', '65%'),
                _buildWeatherDetail(Icons.air, 'Wind', '12 km/h'),
                _buildWeatherDetail(Icons.visibility, 'Visibility', '10 km'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _build7DayForecast() {
    final forecast = [
      {'day': 'Mon', 'icon': Icons.wb_sunny, 'temp': '29°'},
      {'day': 'Tue', 'icon': Icons.cloud, 'temp': '26°'},
      {'day': 'Wed', 'icon': Icons.grain, 'temp': '24°'},
      {'day': 'Thu', 'icon': Icons.wb_sunny, 'temp': '30°'},
      {'day': 'Fri', 'icon': Icons.cloud_queue, 'temp': '27°'},
      {'day': 'Sat', 'icon': Icons.wb_sunny, 'temp': '31°'},
      {'day': 'Sun', 'icon': Icons.grain, 'temp': '25°'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('7-Day Forecast', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            itemBuilder: (context, index) {
              final item = forecast[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['day'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Icon(item['icon'] as IconData, color: Colors.amber),
                      const SizedBox(height: 10),
                      Text(item['temp'] as String),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

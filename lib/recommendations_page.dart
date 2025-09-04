import 'package:flutter/material.dart';
import 'package:farm_flow/services/weather_service.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  List<String> _fertilizerRecs = ['Loading...'];
  List<String> _irrigationRecs = ['Loading...'];
  List<String> _pestControlRecs = ['Loading...'];

  @override
  void initState() {
    super.initState();
    _fetchDataAndGenerateRecs();
  }

  Future<void> _fetchDataAndGenerateRecs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.fetchAllWeatherData();
      setState(() {
        _weatherData = data;
        _generateAiRecommendations();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _generateAiRecommendations() {
    if (_weatherData == null) {
      _fertilizerRecs = _irrigationRecs = _pestControlRecs = ['Could not generate recommendations.'];
      return;
    }

    // Default recommendations
    _fertilizerRecs = ['Adjust NPK ratios based on soil tests and crop stage.'];
    _irrigationRecs = ['Check soil moisture directly for optimal irrigation timing.'];
    _pestControlRecs = ['Scout for pests regularly and follow Integrated Pest Management (IPM) practices.'];

    // Data points from services
    final openWeather = _weatherData!['openWeather'];
    final tomorrow = _weatherData!['tomorrow'];
    final nasaPower = _weatherData!['nasaPower'];

    if (openWeather == null || tomorrow == null || nasaPower == null) return;

    final temp = openWeather['main']?['temp'] ?? 0.0;
    final humidity = openWeather['main']?['humidity'] ?? 0.0;
    final precipChance = tomorrow['timelines']?['daily']?[0]?['values']?['precipitationProbabilityAvg'] ?? 0.0;
    final solarRadiation = nasaPower['properties']?['parameter']?['ALLSKY_SFC_SW_DWN']?.values.last ?? 0.0;
    final evap = nasaPower['properties']?['parameter']?['EVAP']?.values.last ?? 0.0;

    // Fertilizer Logic
    if (solarRadiation > 5.0 && temp > 20 && temp < 32) {
      _fertilizerRecs.add('☀️ Optimal growing conditions detected. Ensure adequate Nitrogen to support vigorous growth.');
    } else if (temp > 35) {
      _fertilizerRecs.add('🔥 High heat stress possible. Consider a Potassium supplement to improve crop resilience.');
    }

    // Irrigation Logic
    if (precipChance > 50) {
      _irrigationRecs = ['🌧️ High chance of rain ($precipChance%). Postpone irrigation.'];
    } else if (evap > 5.0) {
      _irrigationRecs = ['☀️ High evapotranspiration ($evap mm/day). Irrigate your crops to prevent water stress.'];
    } else if (temp > 30 && humidity < 40) {
      _irrigationRecs.add('🔥 Hot and dry conditions. Your crops may need water soon.');
    }

    // Pest & Disease Logic
    if (precipChance > 40) {
      _pestControlRecs.add('💧 High chance of rain. Postpone pesticide/fungicide application.');
    } else if (humidity > 80) {
      _pestControlRecs.add('🌫️ High humidity ($humidity%) increases the risk of fungal diseases. Monitor crops closely.');
    } else {
      _pestControlRecs.add('✅ Weather is favorable for field activities.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDataAndGenerateRecs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       Text(
                        '📍 For location: ${_weatherData!['city']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildRecommendationCard(
                        icon: Icons.eco,
                        title: 'Fertilizer & Nutrients',
                        recommendations: _fertilizerRecs,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 20),
                      _buildRecommendationCard(
                        icon: Icons.water_drop,
                        title: 'Irrigation Schedule',
                        recommendations: _irrigationRecs,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      _buildRecommendationCard(
                        icon: Icons.bug_report,
                        title: 'Pest & Disease Control',
                        recommendations: _pestControlRecs,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRecommendationCard(
      {required IconData icon, required String title, required List<String> recommendations, required Color color}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('• $rec', style: const TextStyle(fontSize: 16)),
                )),
          ],
        ),
      ),
    );
  }
}

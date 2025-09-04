import 'package:flutter/material.dart';
import 'package:farm_flow/services/weather_service.dart';

class IrrigationPage extends StatefulWidget {
  const IrrigationPage({super.key});

  @override
  State<IrrigationPage> createState() => _IrrigationPageState();
}

class _IrrigationPageState extends State<IrrigationPage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _recommendation;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.fetchAllWeatherData();
      setState(() {
        _weatherData = data;
        _generateIrrigationRecommendation();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _generateIrrigationRecommendation() {
    if (_weatherData == null) {
      _recommendation = 'Could not fetch weather data to make a recommendation.';
      return;
    }

    final openWeather = _weatherData!['openWeather'];
    final tomorrow = _weatherData!['tomorrow'];
    final nasaPower = _weatherData!['nasaPower'];

    if (openWeather == null || tomorrow == null || nasaPower == null) {
      _recommendation = 'Incomplete weather data. Cannot generate a precise recommendation.';
      return;
    }

    final temp = openWeather['main']?['temp'] ?? 0.0;
    final humidity = openWeather['main']?['humidity'] ?? 0.0;
    final precip = tomorrow['timelines']?['daily']?[0]?['values']?['precipitationProbabilityAvg'] ?? 0.0;
    final evap = nasaPower['properties']?['parameter']?['EVAP']?.values.last ?? 0.0;

    if (precip > 50) {
      _recommendation = '🌧️ High chance of rain ($precip%). No need to irrigate.';
    } else if (evap > 5.0) {
      _recommendation = '☀️ High evapotranspiration ($evap). It is critical to irrigate your crops to avoid water stress.';
    } else if (temp > 30 && humidity < 40) {
      _recommendation = '🔥 High temperature ($temp°C) and low humidity ($humidity%). Consider irrigating your crops soon.';
    } else {
      _recommendation = '✅ Conditions are moderate. Check soil moisture directly for optimal irrigation timing.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💧 Irrigation Schedule'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeatherData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _weatherData == null
                  ? const Center(child: Text('No data available.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '📍 Location: ${_weatherData!['city']}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildRecommendationCard(),
                          const SizedBox(height: 20),
                          _buildDetailedWeatherCards(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              '💡 AI Recommendation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
            ),
            const SizedBox(height: 10),
            Text(
              _recommendation ?? 'No recommendation available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.blue.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedWeatherCards() {
    return Column(
      children: [
        _buildWeatherDetailCard(
          title: 'Short-Term Forecast',
          icon: Icons.wb_sunny,
          data: {
            'Temperature': '${_weatherData!['openWeather']?['main']?['temp'] ?? 'N/A'}°C',
            'Humidity': '${_weatherData!['openWeather']?['main']?['humidity'] ?? 'N/A'}%',
            'Rain Chance': '${_weatherData!['tomorrow']?['timelines']?['daily']?[0]?['values']?['precipitationProbabilityAvg'] ?? 'N/A'}%',
          },
        ),
        const SizedBox(height: 16),
        _buildWeatherDetailCard(
          title: 'Scientific Model Data',
          icon: Icons.science,
          data: {
            'Evapotranspiration': '${_weatherData!['nasaPower']?['properties']?['parameter']?['EVAP']?.values.last ?? 'N/A'} mm/day',
            'Solar Radiation': '${_weatherData!['nasaPower']?['properties']?['parameter']?['ALLSKY_SFC_SW_DWN']?.values.last ?? 'N/A'} kWh/m^2/day',
          },
        ),
      ],
    );
  }

  Widget _buildWeatherDetailCard({required String title, required IconData icon, required Map<String, String> data}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 16)),
                  Text(entry.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

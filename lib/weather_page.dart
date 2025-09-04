import 'package:flutter/material.dart';
import 'package:farm_flow/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  final String? crop;

  const WeatherPage({super.key, this.crop});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crop != null ? '🌦 Weather - ${widget.crop}' : '🌦 Weather Updates'),
        backgroundColor: Colors.green,
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
                  ? const Center(child: Text('No weather data available.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWeatherCard('📍 City', _weatherData!['city'], Icons.location_on, Colors.blue),
                          const SizedBox(height: 16),
                          _buildOpenWeatherCard(_weatherData!['openWeather']),
                          const SizedBox(height: 16),
                          _buildTomorrowIoCard(_weatherData!['tomorrow']),
                          const SizedBox(height: 16),
                          _buildNasaPowerCard(_weatherData!['nasaPower']),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildWeatherCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$title: $value',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenWeatherCard(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Weather (OpenWeatherMap)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Temperature: ${data['main']['temp']}°C'),
            Text('Condition: ${data['weather'][0]['main']}'),
            Text('Humidity: ${data['main']['humidity']}%'),
            Text('Wind Speed: ${data['wind']['speed']} m/s'),
          ],
        ),
      ),
    );
  }

  Widget _buildTomorrowIoCard(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();

    // Simplified representation of forecast
    final forecast = data['timelines']?['daily']?[0]?['values'];
    if (forecast == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Short-term Forecast (Tomorrow.io)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Max Temperature: ${forecast['temperatureMax']}°C'),
            Text('Min Temperature: ${forecast['temperatureMin']}°C'),
            Text('Precipitation: ${forecast['precipitationProbabilityAvg']}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildNasaPowerCard(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();

    // Simplified representation of NASA POWER data
    final properties = data['properties']?['parameter'];
    if (properties == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Long-term Data (NASA POWER)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Evapotranspiration: ${properties['EVAP']?.values.last ?? 'N/A'}'),
            Text('Solar Radiation: ${properties['ALLSKY_SFC_SW_DWN']?.values.last ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}

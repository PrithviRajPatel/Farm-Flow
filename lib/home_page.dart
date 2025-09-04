import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ✅ Import Firebase Messaging
import 'package:farm_flow/services/weather_service.dart';
import 'package:farm_flow/mandi_page.dart';
import 'package:farm_flow/weather_page.dart';
import 'package:farm_flow/controls_page.dart';

class HomePage extends StatefulWidget {
  final List<String> crops;
  const HomePage({super.key, this.crops = const []});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    _requestNotificationPermission(); // ✅ Request permission on load
  }

  /// ✅ Request notification permission and get FCM token
  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get the FCM token for this device
    String? token = await messaging.getToken();
    print("Firebase Messaging Token: $token");

    // You would typically send this token to your server to store it against the user.
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
        title: const Text('FarmFlow Dashboard'),
        backgroundColor: Colors.green,
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
                      _buildWelcomeHeader(),
                      const SizedBox(height: 20),
                      if (widget.crops.isNotEmpty) _buildCropsSummary(),
                      const SizedBox(height: 20),
                      _buildWeatherSummary(),
                      const SizedBox(height: 20),
                      _buildNavigationGrid(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWelcomeHeader() {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Welcome, Farmer!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  Widget _buildCropsSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Your Selected Crops',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.crops.join(', '),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWeatherSummary() {
    final openWeather = _weatherData?['openWeather'];
    if (openWeather == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Weather in ${_weatherData!['city']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${openWeather['main']['temp']}°C, ${openWeather['weather'][0]['main']}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildNavCard(
          title: 'Mandi Prices',
          icon: Icons.store,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MandiPage())),
        ),
        _buildNavCard(
          title: 'Weather Details',
          icon: Icons.wb_sunny,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherPage())),
        ),
        _buildNavCard(
          title: 'Irrigation',
          icon: Icons.water_drop,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ControlsPage())),
        ),
      ],
    );
  }

  Widget _buildNavCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

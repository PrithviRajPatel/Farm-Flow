import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

// Service to handle device location
class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      // First, request permission
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle the case where the user denies permission
        print("Location permission denied.");
        return null;
      }

      // If permission is granted, get the position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}


class WeatherService {
  static const String _openWeatherApiKey = "296923fadda6cb9bd560d4e8288ec552";
  static const String _nasaApiKey = "6yBIlI2XSXRu18s37nMcypJ4LPR2Z3Tr3scqjsD1";
  static const String _tomorrowApiKey = "YzWGCyy3iIjeBa2e0zDFgGbqmJbBiopq";

  final LocationService _locationService = LocationService();

  Future<Map<String, dynamic>> fetchAllWeatherData() async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      throw Exception('Location permission not granted or location could not be fetched.');
    }

    final lat = position.latitude;
    final lon = position.longitude;

    // Fetch all data in parallel
    final results = await Future.wait([
      _fetchOpenWeatherData(lat, lon),
      _fetchTomorrowData(lat, lon),
      _fetchNasaPowerData(lat, lon),
    ]);

    final openWeatherData = results[0];
    final tomorrowData = results[1];
    final nasaPowerData = results[2];

    return {
      'openWeather': openWeatherData,
      'tomorrow': tomorrowData,
      'nasaPower': nasaPowerData,
      'city': openWeatherData?['name'] ?? 'Unknown',
    };
  }

  Future<Map<String, dynamic>?> _fetchOpenWeatherData(double lat, double lon) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_openWeatherApiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchTomorrowData(double lat, double lon) async {
    final url = 'https://api.tomorrow.io/v4/weather/forecast?location=$lat,$lon&apikey=$_tomorrowApiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchNasaPowerData(double lat, double lon) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 365)); // Fetch for a year
    final startDateFormatted = DateFormat('yyyyMMdd').format(startDate);
    final endDateFormatted = DateFormat('yyyyMMdd').format(endDate);

    final url =
        'https://power.larc.nasa.gov/api/temporal/daily/point?parameters=T2M,RH2M,PRECTOTCORR,ALLSKY_SFC_SW_DWN,EVAP&community=AG&longitude=$lon&latitude=$lat&start=$startDateFormatted&end=$endDateFormatted&format=JSON&api_key=$_nasaApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}

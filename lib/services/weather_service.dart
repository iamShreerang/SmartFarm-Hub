import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';
import '../utils/app_theme.dart';

class WeatherService {
  final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  final String _base = AppStrings.weatherApiBase;

  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }
    return Geolocator.getCurrentPosition();
  }

  Future<WeatherData> getCurrentWeather({String? cityName}) async {
    String url;
    if (cityName != null && cityName.isNotEmpty) {
      url = '$_base/weather?q=$cityName&appid=$_apiKey&units=metric';
    } else {
      final pos = await _getPosition();
      url = '$_base/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$_apiKey&units=metric';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather: ${response.statusCode}');
    }
    final json = jsonDecode(response.body);
    final forecast = await _getForecast(
      cityName: cityName,
      lat: json['coord']?['lat'],
      lon: json['coord']?['lon'],
    );
    return WeatherData.fromJson(json, forecast: forecast);
  }

  Future<List<ForecastDay>> _getForecast({
    String? cityName,
    double? lat,
    double? lon,
  }) async {
    String url;
    if (cityName != null && cityName.isNotEmpty) {
      url = '$_base/forecast/daily?q=$cityName&cnt=7&appid=$_apiKey&units=metric';
    } else if (lat != null && lon != null) {
      url = '$_base/forecast/daily?lat=$lat&lon=$lon&cnt=7&appid=$_apiKey&units=metric';
    } else {
      return [];
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return [];
    final json = jsonDecode(response.body);
    final list = json['list'] as List? ?? [];
    return list.map((e) => ForecastDay.fromJson(e)).toList();
  }
}

import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final _weatherService = WeatherService();

  WeatherData? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetched;

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather({String? cityName}) async {
    // Cache for 30 minutes
    if (_weather != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!).inMinutes < 30 &&
        cityName == null) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _weather = await _weatherService.getCurrentWeather(cityName: cityName);
      _lastFetched = DateTime.now();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

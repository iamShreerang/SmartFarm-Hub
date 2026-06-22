class WeatherData {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String description;
  final String iconCode;
  final double rainChance; // 0-100
  final List<ForecastDay> forecast;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
    this.rainChance = 0,
    this.forecast = const [],
  });

  factory WeatherData.fromJson(Map<String, dynamic> json,
      {List<ForecastDay> forecast = const []}) {
    return WeatherData(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      rainChance: json['pop'] != null ? (json['pop'] as num).toDouble() * 100 : 0,
      forecast: forecast,
    );
  }

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  String get farmingAdvice {
    if (rainChance > 70) return 'Rain expected — avoid watering and pesticide application today.';
    if (temperature > 38) return 'Extreme heat — water crops in the early morning or evening.';
    if (windSpeed > 10) return 'Strong winds — avoid spraying pesticides or fertilizers.';
    if (humidity < 30) return 'Low humidity — increase irrigation frequency.';
    return 'Good conditions for farming activities.';
  }
}

class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String iconCode;
  final String description;
  final double rainChance;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.iconCode,
    required this.description,
    this.rainChance = 0,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) => ForecastDay(
        date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        minTemp: (json['temp']['min'] as num).toDouble(),
        maxTemp: (json['temp']['max'] as num).toDouble(),
        iconCode: json['weather'][0]['icon'] ?? '01d',
        description: json['weather'][0]['description'] ?? '',
        rainChance: json['pop'] != null ? (json['pop'] as num).toDouble() * 100 : 0,
      );

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

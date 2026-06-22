import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/weather_provider.dart';
import '../../models/weather.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WeatherProvider>().fetchWeather(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () {
                    if (_searchCtrl.text.trim().isNotEmpty) {
                      context
                          .read<WeatherProvider>()
                          .fetchWeather(cityName: _searchCtrl.text.trim());
                    }
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  context.read<WeatherProvider>().fetchWeather(cityName: val.trim());
                }
              },
            ),
          ),
          Expanded(
            child: weather.isLoading
                ? const Center(child: CircularProgressIndicator())
                : weather.errorMessage != null
                    ? ErrorView(
                        message: weather.errorMessage!,
                        onRetry: () =>
                            context.read<WeatherProvider>().fetchWeather(),
                      )
                    : weather.weather == null
                        ? const Center(
                            child: Text('No weather data. Search a city or enable location.'))
                        : _WeatherContent(data: weather.weather!),
          ),
        ],
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherData data;
  const _WeatherContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CurrentWeatherCard(data: data),
          const SizedBox(height: 16),
          _FarmingAdviceCard(advice: data.farmingAdvice),
          const SizedBox(height: 16),
          _WeatherStatsRow(data: data),
          const SizedBox(height: 16),
          if (data.forecast.isNotEmpty) ...[
            const Text('7-Day Forecast',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _ForecastList(forecast: data.forecast),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final WeatherData data;
  const _CurrentWeatherCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            data.cityName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: data.iconUrl,
                height: 80,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.wb_sunny,
                  size: 80,
                  color: Colors.yellow,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w300),
                  ),
                  Text(
                    data.description.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    'Feels like ${data.feelsLike.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FarmingAdviceCard extends StatelessWidget {
  final String advice;
  const _FarmingAdviceCard({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Farming Advice',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(advice, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherStatsRow extends StatelessWidget {
  final WeatherData data;
  const _WeatherStatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${data.humidity.toInt()}%',
                color: const Color(0xFF0288D1))),
        const SizedBox(width: 8),
        Expanded(
            child: _StatCard(
                icon: Icons.air,
                label: 'Wind Speed',
                value: '${data.windSpeed.toStringAsFixed(1)} m/s',
                color: const Color(0xFF455A64))),
        const SizedBox(width: 8),
        Expanded(
            child: _StatCard(
                icon: Icons.umbrella,
                label: 'Rain Chance',
                value: '${data.rainChance.toInt()}%',
                color: const Color(0xFF1565C0))),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ForecastList extends StatelessWidget {
  final List<ForecastDay> forecast;
  const _ForecastList({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: forecast
          .map((day) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        DateFormat('EEE, d MMM').format(day.date),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    CachedNetworkImage(
                      imageUrl: day.iconUrl,
                      height: 36,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.cloud, size: 36),
                    ),
                    Expanded(
                      child: Text(
                        day.description,
                        style: TextStyle(
                            color: AppColors.textGrey, fontSize: 12),
                      ),
                    ),
                    Text(
                      '${day.minTemp.toInt()}° / ${day.maxTemp.toInt()}°',
                      style:
                          const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${day.rainChance.toInt()}%',
                      style: const TextStyle(
                          color: Color(0xFF1565C0), fontSize: 12),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

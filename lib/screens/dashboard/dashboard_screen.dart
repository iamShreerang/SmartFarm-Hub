import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../providers/crop_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../crops/crop_list_screen.dart';
import '../weather/weather_screen.dart';
import '../disease/disease_screen.dart';
import '../chatbot/chatbot_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final crops = context.watch<CropProvider>();
    final tasks = context.watch<TaskProvider>();
    final weather = context.watch<WeatherProvider>();
    final profile = auth.profile;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<WeatherProvider>().fetchWeather(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_greeting()}, ${profile?.name.split(' ').first ?? 'Farmer'}! 👋',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text('SmartFarm Hub',
                        style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WeatherCard(weather: weather),
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: 'Quick Actions',
                    ),
                    const SizedBox(height: 12),
                    _QuickActionsGrid(),
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: 'My Crops',
                      actionLabel: 'View All',
                      onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CropListScreen())),
                    ),
                    const SizedBox(height: 12),
                    crops.crops.isEmpty
                        ? _EmptyCropsCard()
                        : _CropsOverview(crops: crops),
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: 'Upcoming Tasks',
                      actionLabel: 'See All',
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    tasks.pendingTasks.isEmpty
                        ? _NoTasksCard()
                        : _UpcomingTasksList(tasks: tasks),
                    if (tasks.overdueTasks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _OverdueAlert(count: tasks.overdueTasks.length),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherProvider weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather.isLoading) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (weather.weather == null) {
      return GestureDetector(
        onTap: () => context.read<WeatherProvider>().fetchWeather(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, size: 40, color: AppColors.textGrey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  weather.errorMessage ?? 'Tap to load weather',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
              const Icon(Icons.refresh, color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    final w = weather.weather!;
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: w.iconUrl,
                  height: 60,
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.wb_sunny, size: 60, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${w.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(w.cityName,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                      Text(
                        w.description.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _WeatherStat(
                        icon: Icons.water_drop,
                        value: '${w.humidity.toInt()}%'),
                    const SizedBox(height: 8),
                    _WeatherStat(
                        icon: Icons.air,
                        value: '${w.windSpeed.toStringAsFixed(1)}m/s'),
                    const SizedBox(height: 8),
                    _WeatherStat(
                        icon: Icons.umbrella,
                        value: '${w.rainChance.toInt()}%'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Colors.yellow, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      w.farmingAdvice,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _WeatherStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
          icon: Icons.grass,
          label: 'My Crops',
          color: const Color(0xFF2E7D32),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CropListScreen()))),
      _QuickAction(
          icon: Icons.camera_alt,
          label: 'Scan Disease',
          color: const Color(0xFFE65100),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DiseaseScreen()))),
      _QuickAction(
          icon: Icons.wb_sunny,
          label: 'Weather',
          color: const Color(0xFF1565C0),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WeatherScreen()))),
      _QuickAction(
          icon: Icons.smart_toy,
          label: 'AI Assistant',
          color: const Color(0xFF6A1B9A),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()))),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      children: actions
          .map((a) => GestureDetector(
                onTap: a.onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: a.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(a.icon, color: a.color, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(a.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

class _CropsOverview extends StatelessWidget {
  final CropProvider crops;
  const _CropsOverview({required this.crops});

  @override
  Widget build(BuildContext context) {
    final displayCrops = crops.crops.take(3).toList();
    return Column(
      children: displayCrops.map((crop) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.grass, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(crop.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(crop.growthStage.name.toUpperCase(),
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 12)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: crop.growthProgress,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.primary,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${crop.daysToHarvest}d',
                      style: TextStyle(
                        color: crop.daysToHarvest < 7
                            ? AppColors.warning
                            : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('to harvest',
                        style: TextStyle(
                            color: AppColors.textGrey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyCropsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.grass, size: 48, color: AppColors.primary.withOpacity(0.4)),
            const SizedBox(height: 8),
            const Text('No crops yet'),
            const SizedBox(height: 12),
            AppButton(
              label: 'Add Your First Crop',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CropListScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTasksList extends StatelessWidget {
  final TaskProvider tasks;
  const _UpcomingTasksList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final upcoming = tasks.pendingTasks.take(3).toList();
    return Column(
      children: upcoming.map((task) {
        final icon = _taskIcon(task.type.name);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            title: Text(task.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              _formatDate(task.scheduledDate),
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            trailing: task.isOverdue
                ? const Icon(Icons.warning, color: AppColors.warning)
                : null,
          ),
        );
      }).toList(),
    );
  }

  IconData _taskIcon(String type) {
    switch (type) {
      case 'watering':
        return Icons.water_drop;
      case 'fertilization':
        return Icons.science;
      case 'pesticide':
        return Icons.bug_report;
      case 'harvesting':
        return Icons.agriculture;
      default:
        return Icons.task;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) return 'Overdue by ${-diff} day(s)';
    return 'In $diff days';
  }
}

class _NoTasksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 12),
            const Text('No pending tasks — you\'re all caught up! 🎉'),
          ],
        ),
      ),
    );
  }
}

class _OverdueAlert extends StatelessWidget {
  final int count;
  const _OverdueAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count task(s) are overdue! Please complete them.',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

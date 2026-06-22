import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/crop_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'crops/crop_list_screen.dart';
import 'calendar/calendar_screen.dart';
import 'knowledge/knowledge_screen.dart';
import 'profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CropListScreen(),
    CalendarScreen(),
    KnowledgeScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final userId = context.read<ap.AuthProvider>().profile?.uid;
    if (userId != null) {
      context.read<CropProvider>().watchCrops(userId);
      context.read<TaskProvider>().watchTasks(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Crops'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Knowledge'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

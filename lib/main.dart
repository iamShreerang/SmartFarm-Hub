import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/task_provider.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: '.env');
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'SmartFarm Hub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        switch (auth.status) {
          case AuthStatus.authenticated:
            return const HomeShell();
          case AuthStatus.unauthenticated:
            return const SignInScreen();
          default:
            return const SplashScreen();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:super_locker/config/app_config.dart';
import 'package:super_locker/services/auth_service.dart';
import 'package:super_locker/services/password_service.dart';
import 'package:super_locker/services/encryption_service.dart';
import 'package:super_locker/services/auto_lock_service.dart';
import 'package:super_locker/screens/splash_screen.dart';
import 'package:super_locker/screens/email_auth_screen.dart';
import 'package:super_locker/screens/device_auth_screen.dart';
import 'package:super_locker/screens/performance_analysis_screen.dart';

import 'package:super_locker/screens/home_screen.dart';
import 'package:super_locker/screens/add_password_screen.dart';
import 'package:super_locker/screens/search_password_screen.dart';
import 'package:super_locker/screens/password_generator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SuperLockerApp());
}

class SuperLockerApp extends StatefulWidget {
  const SuperLockerApp({super.key});

  @override
  State<SuperLockerApp> createState() => _SuperLockerAppState();
}

class _SuperLockerAppState extends State<SuperLockerApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeAutoLock();
  }

  void _initializeAutoLock() {
    AutoLockService().initialize(
      onAutoLock: (lockLevel) {
        final context = _navigatorKey.currentContext;
        if (context != null) {
          // Handle different lock levels
          switch (lockLevel) {
            case LockLevel.deviceAuth:
              // 5-minute timeout - require device authentication only
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/device-auth',
                (route) => false,
              );
              break;
            case LockLevel.masterKey:
              // 15-minute timeout - require device auth + master key
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/device-auth',
                (route) => false,
              );
              break;
          }
        }
      },
      onUserActivity: () {
        // Optional: Handle user activity events
        // print('User activity detected');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PasswordService()),
        Provider(create: (_) => EncryptionService()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: AppConfig.appName,
        debugShowCheckedModeBanner: AppConfig.showDebugBanner,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.blue,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/email-auth': (context) => const EmailAuthScreen(),
          '/device-auth': (context) => const DeviceAuthScreen(),
          '/home': (context) => const HomeScreen(),
          '/add-password': (context) => const AddPasswordScreen(),
          '/search-password': (context) => const SearchPasswordScreen(),
          '/password-generator': (context) => const PasswordGeneratorScreen(),
          '/performance': (context) => const PerformanceAnalysisScreen(),
        },
      ),
    );
  }
}

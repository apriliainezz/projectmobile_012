import 'package:responsiah/pages/main_navigation.dart';
import 'package:responsiah/pages/login_page.dart';
import 'package:responsiah/services/local_notification_service.dart';
// import 'package:responsiah/services/notification_service.dart';
import 'package:responsiah/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize SessionService (which will initialize DatabaseHelper)
  await SessionService.init();

  // Initialize Notification Service
  await LocalNotificationService.initialize();
  await LocalNotificationService.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Notification initialization is now handled in main()
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Mobile Inez',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder<bool>(
        future: Future.value(SessionService.isLoggedIn),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            final isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? const MainNavigation() : const LoginPage();
          }
        },
      ),
    );
  }
}

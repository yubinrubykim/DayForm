import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/question_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.instance.init();
  await NotificationService.instance.init();
  await NotificationService.instance.initBackgroundWork();

  // Cancel all pending notifications on app start to prevent duplicates
  await NotificationService.instance.cancelAllNotifications();

  await QuestionService.instance.loadQuestions();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Schedule notification when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      NotificationService.instance.scheduleNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘의 질문',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

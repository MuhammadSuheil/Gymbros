import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbros/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/services/notification_service.dart';

// ViewModels
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/tracking/viewmodel/workout_viewmodel.dart';
import 'features/exercise_selection/viewmodel/exercise_viewmodel.dart';
import 'features/history/viewmodel/history_viewmodel.dart';
import 'features/streak/viewmodel/streak_viewmodel.dart';

// Screens
import 'features/main_screen/main_screen.dart';
import 'features/auth/view/login_screen.dart';

const supabaseUrl = 'https://tbyjchwkedxhgkdefrco.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);
  await notificationService.initNotifications();

  try {
    await sb.Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    runApp(
      MultiProvider(
        providers: [
          Provider<NotificationService>.value(value: notificationService),
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
          ChangeNotifierProvider(create: (_) => ExerciseViewModel()..fetchInitialExercises()),
          ChangeNotifierProvider(create: (_) => HistoryViewModel()),
          ChangeNotifierProvider(create: (_) => StreakViewModel()..fetchAllStreakData()),
        ],
        child: const GymBrosApp(),
      ),
    );
  } catch (e) {
    runApp(InitializationErrorApp(error: e.toString()));
  }
}

class InitializationErrorApp extends StatelessWidget {
  final String error;
  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Failed to initialize app.\nError: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class GymBrosApp extends StatelessWidget {
  const GymBrosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GymBros',
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    print("[AuthWrapper] Building...");
    
    return StreamBuilder<fb.User?>(
      stream: fb.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print("[AuthWrapper] StreamBuilder state: ${snapshot.connectionState}");
        print("[AuthWrapper] Has data: ${snapshot.hasData}, User: ${snapshot.data?.uid}");
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("[AuthWrapper] Showing loading screen");
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          print("[AuthWrapper] User logged in, showing MainScreen");
          return const MainScreen();
        }
        
        print("[AuthWrapper] No user, showing LoginScreen");
        return const LoginScreen();
      },
    );
  }
}
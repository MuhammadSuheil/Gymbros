// test/widget_test.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// Firebase + Mocks
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// App imports
import 'package:gymbros/core/services/notification_service.dart';
import 'package:gymbros/core/theme/app_theme.dart';
import 'package:gymbros/features/auth/view/login_screen.dart';
import 'package:gymbros/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:gymbros/features/exercise_selection/viewmodel/exercise_viewmodel.dart';
import 'package:gymbros/features/history/viewmodel/history_viewmodel.dart';
import 'package:gymbros/features/main_screen/main_screen.dart';
import 'package:gymbros/features/streak/viewmodel/streak_viewmodel.dart';
import 'package:gymbros/features/tracking/viewmodel/workout_viewmodel.dart';
import 'package:gymbros/main.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}
class MockWorkoutViewModel extends Mock implements WorkoutViewModel {}
class MockExerciseViewModel extends Mock implements ExerciseViewModel {}
class MockHistoryViewModel extends Mock implements HistoryViewModel {}
class MockStreakViewModel extends Mock implements StreakViewModel {}
class MockNotificationService extends Mock implements NotificationService {}

Future<void> setupMockFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockWorkoutViewModel mockWorkoutViewModel;
  late MockExerciseViewModel mockExerciseViewModel;
  late MockHistoryViewModel mockHistoryViewModel;
  late MockStreakViewModel mockStreakViewModel;
  late MockNotificationService mockNotificationService;

  setUpAll(() async {
    await setupMockFirebase();
  });

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockWorkoutViewModel = MockWorkoutViewModel();
    mockExerciseViewModel = MockExerciseViewModel();
    mockHistoryViewModel = MockHistoryViewModel();
    mockStreakViewModel = MockStreakViewModel();
    mockNotificationService = MockNotificationService();

    // Biar gak error listener
    for (var vm in [
      mockAuthViewModel,
      mockWorkoutViewModel,
      mockExerciseViewModel,
      mockHistoryViewModel,
      mockStreakViewModel
    ]) {
      when(() => vm.addListener(any())).thenAnswer((_) {});
      when(() => vm.removeListener(any())).thenAnswer((_) {});
    }
  });

  Widget createTestApp({required fb.FirebaseAuth auth}) {
    return MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: mockNotificationService),
        ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
        ChangeNotifierProvider<WorkoutViewModel>.value(value: mockWorkoutViewModel),
        ChangeNotifierProvider<ExerciseViewModel>.value(value: mockExerciseViewModel),
        ChangeNotifierProvider<HistoryViewModel>.value(value: mockHistoryViewModel),
        ChangeNotifierProvider<StreakViewModel>.value(value: mockStreakViewModel),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: StreamBuilder<fb.User?>(
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) return const MainScreen();
            return const LoginScreen();
          },
        ),
      ),
    );
  }

  testWidgets('shows LoginScreen when user is logged out', (tester) async {
    final mockAuth = MockFirebaseAuth(signedIn: false);
    await tester.pumpWidget(createTestApp(auth: mockAuth));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);
  });

  testWidgets('shows MainScreen when user is logged in', (tester) async {
    final mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        isAnonymous: false,
        uid: '12345',
        email: 'test@gymbros.com',
      ),
      signedIn: true,
    );

    await tester.pumpWidget(createTestApp(auth: mockAuth));
    await tester.pumpAndSettle();

    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}

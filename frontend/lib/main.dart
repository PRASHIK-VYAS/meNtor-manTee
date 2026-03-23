// flutter run --dart-define-from-file=.env
// tree -I "build|.dart_tool|.git|.idea|.vscode|node_modules|coverage|test/.dart_tool|*.lock"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/mentor_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/student/student_main_screen.dart';
import 'screens/mentor/mentor_main_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize notification service but don't let it block the entire app if it fails
    await NotificationService().init().timeout(const Duration(seconds: 5));
    print('Notification service initialized');
  } catch (e) {
    print('Notification service failed to initialize: $e');
  }

  runApp(const MenToraApp());
}

class MenToraApp extends StatelessWidget {
  const MenToraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, StudentProvider>(
          create: (_) => StudentProvider(),
          update: (_, authProvider, previous) =>
              (previous ?? StudentProvider())..updateAuth(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MentorProvider>(
          create: (_) => MentorProvider(),
          update: (_, authProvider, previous) =>
              (previous ?? MentorProvider())..updateAuth(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, authProvider, previous) =>
              (previous ?? NotificationProvider())..updateAuth(authProvider),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp(
          title: 'MenTora',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          home: auth.isAuthenticated
              ? (auth.userRole == 'student'
                  ? const StudentMainScreen()
                  : const MentorMainScreen())
              : const LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/student-main': (context) => const StudentMainScreen(),
            '/mentor-main': (context) => const MentorMainScreen(),
          },
          onGenerateRoute: (settings) {
            // Handle dynamic routes if needed
            return null;
          },
        ),
      ),
    );
  }
}

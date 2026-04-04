// frontend\lib\providers\auth_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/student_model.dart';
import '../models/mentor_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _userId;
  String? _email;
  String? _userRole; // "student" or "mentor"
  StudentModel? _student;
  MentorModel? _mentor;
  bool _isLoading = false;
  Timer? _notificationTimer;

  String? get userId => _userId;
  String? get email => _email;
  String? get userRole => _userRole;
  StudentModel? get student => _student;
  MentorModel? get mentor => _mentor;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userId != null;

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    print('DEBUG: Starting tryAutoLogin');
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        print('DEBUG: No token found');
        return;
      }

      print('DEBUG: Fetching profile with token');
      final response = await _apiService.get('/auth/profile');
      print('DEBUG: Profile response: $response');

      if (response != null) {
        _userId = response['id']?.toString();
        _email = response['email']?.toString();
        _userRole = response['role']?.toString().toLowerCase();

        print('DEBUG: User ID: $_userId, Role: $_userRole');

        if (_userRole == 'student') {
          print('DEBUG: Fetching student details');
          // Update endpoint to match backend: /api/students/profile/:studentId
          print('DEBUG: Fetching student details for User ID: $_userId');
          final studentData =
              await _apiService.get('/students/profile/$_userId');
          _student = StudentModel.fromMap(studentData);
        } else if (_userRole == 'mentor') {
          print('DEBUG: Fetching mentor details');
          // Backend: /api/mentors/profile (using token)
          final mentorData = await _apiService.get('/mentors/profile');
          _mentor = MentorModel.fromMap(mentorData);
        }

        print('DEBUG: Auth successful, notifying listeners');
        _startNotificationPolling();
        notifyListeners();
      }
    } catch (e) {
      print('Auto-login error (possibly intermittent): $e');
      
      // Only sign out (and delete token) if it's clearly an auth failure (401)
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('401') || 
          errorStr.contains('unauthorized') || 
          errorStr.contains('invalid or expired token')) {
        print('DEBUG: Auth failure detected, signing out.');
        await signOut();
      } else {
        print('DEBUG: Non-auth error (500, network, etc.). Retaining token.');
      }
      
      rethrow; 
    }
  }

  void _startNotificationPolling() {
    _stopNotificationPolling(); // ensure no duplicates

    // Poll every 15 seconds
    _notificationTimer =
        Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (!isAuthenticated) {
        _stopNotificationPolling();
        return;
      }

      try {
        final response = await _apiService.get('/notifications/unread');
        if (response != null && response is List) {
          for (var notif in response) {
            // Show Local Notification
            await NotificationService().showNotification(
              id: notif['id'].hashCode,
              title: notif['title'] ?? 'New Notification',
              body: notif['message'] ?? '',
            );

            // Mark as read immediately to avoid showing it again
            await _apiService.patch('/notifications/${notif['id']}/read', {});
          }
        }
      } catch (e) {
        print('Notification Poll Error: $e');
      }
    });
  }

  void _stopNotificationPolling() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['accessToken'] != null) {
        await _storage.write(key: 'jwt_token', value: response['accessToken']);

        // Fetch profile immediately after login
        await tryAutoLogin();
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendRegistrationOTP(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.post('/auth/send-registration-otp', {
        'email': email.trim(),
      });

      return true;
    } catch (e) {
      print('Registration OTP request error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String otp, // Add OTP requirement
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Only student registration is allowed from frontend
      await _apiService.post('/auth/register/student', {
        'email': email,
        'password': password,
        'otp': otp, // Send OTP to backend
        ...?additionalData,
      });

      // User requested to go back to login page after registration
      // so we dont auto-login anymore
      return true; 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    _stopNotificationPolling();
    await _storage.delete(key: 'jwt_token');
    _userId = null;
    _email = null;
    _userRole = null;
    _student = null;
    _mentor = null;
    notifyListeners();
  }

  // --- FORGOT PASSWORD FLOW ---
  Future<String> requestPasswordReset(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.post('/auth/forgot-password', {
        'email': email.trim(),
      });

      return response['dev_otp']?.toString() ?? 'OTP requested successfully';
    } catch (e) {
      print('Forgot password error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.post('/auth/verify-otp', {
        'email': email.trim(),
        'otp': otp.trim(),
      });
      return true;
    } catch (e) {
      print('Verify OTP error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitNewPassword(
      String email, String otp, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.post('/auth/reset-password', {
        'email': email.trim(),
        'otp': otp.trim(),
        'newPassword': newPassword,
      });
      return true;
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

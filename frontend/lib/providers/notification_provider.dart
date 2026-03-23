// frontend\lib\providers\notification_provider.dart
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _localNotificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  String? _lastUserId;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  void updateAuth(AuthProvider authProvider) {
    if (authProvider.isAuthenticated && authProvider.userId != null) {
      if (_lastUserId != authProvider.userId) {
        _lastUserId = authProvider.userId;
        fetchNotifications();
      }
    } else {
      _lastUserId = null;
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final List<dynamic> result = await _apiService.get('/notifications');

      final newNotifications =
          result.map((json) => NotificationModel.fromJson(json)).toList();

      // Check for new notifications to show local push notification
      if (_notifications.isNotEmpty) {
        for (var newNotif in newNotifications) {
          if (!newNotif.isRead &&
              !_notifications.any((n) => n.id == newNotif.id)) {
            _localNotificationService.showNotification(
              id: newNotif.id.hashCode,
              title: newNotif.title,
              body: newNotif.message,
            );
          }
        }
      }

      _notifications = newNotifications;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.patch('/notifications/$id/read', {});

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.post('/notifications/mark-all-read', {});

      _notifications = _notifications
          .map((n) => NotificationModel(
                id: n.id,
                userId: n.userId,
                title: n.title,
                message: n.message,
                type: n.type,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}

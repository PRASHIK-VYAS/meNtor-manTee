import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'NOTIFICATIONS',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isEmpty)
                return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text(
                  'CLEAR ALL',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState('You are all caught up! 🎉');
          }

          return RefreshIndicator(
            onRefresh: provider.fetchNotifications,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationCard(
                  context: context,
                  notification: notification,
                  onTap: () => provider.markAsRead(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationModel notification,
    required VoidCallback onTap,
  }) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'DOCUMENT':
        icon = Icons.description_rounded;
        color = Colors.blue;
        break;
      case 'TASK':
        icon = Icons.assignment_rounded;
        color = Colors.orange;
        break;
      case 'BROADCAST':
        icon = Icons.campaign_rounded;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = Colors.grey;
    }

    final timeStr = DateFormat('MMM d, h:mm a').format(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? const Color(0xFFF5F5F7).withOpacity(0.5)
            : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
        border: notification.isRead
            ? null
            : Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight:
                      notification.isRead ? FontWeight.w700 : FontWeight.w900,
                  fontSize: 16,
                  color: notification.isRead ? Colors.black54 : Colors.black,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                  color: notification.isRead ? Colors.black38 : Colors.black54,
                  fontSize: 13,
                  height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              timeStr,
              style: TextStyle(
                color: Colors.black26,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 80, color: Colors.grey[200]),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/notification_request.dart';
import 'home_screen.dart';
import 'posts_screen.dart' as posts_screen;
import 'profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationRequest> _notifications = [
    NotificationRequest(name: 'Kiki', contact: '+123456789'),
    NotificationRequest(name: 'Leo', contact: '+987654321'),
    NotificationRequest(name: 'Milo', contact: '+192837465'),
  ];

  final List<NotificationRequest> acceptedRequests = [];

  int _currentIndex = 2; // Notifications tab selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final isAccepted = acceptedRequests.contains(notification);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.pets, color: Colors.white),
              ),
              title: Text('${notification.name} wants to contact you'),
              subtitle: isAccepted ? Text('Contact: ${notification.contact}') : null,
              trailing: isAccepted
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    acceptedRequests.add(notification);
                  });
                },
                child: const Text('Accept', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),

      // ✅ Bottom Navigation Bar;
    );
  }
}

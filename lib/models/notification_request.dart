// screens/notifications_screen.dart
import 'package:flutter/material.dart';

class NotificationRequest {
  final String name;
  final String contact;
  bool accepted;

  NotificationRequest({
    required this.name,
    required this.contact,
    this.accepted = false,
  });
}

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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('${notification.name} wants to send request for contacting'),
            subtitle: notification.accepted ? Text('Contact: ${notification.contact}') : null,
            trailing: notification.accepted
                ? const Icon(Icons.check, color: Colors.green)
                : TextButton(
              onPressed: () {
                setState(() {
                  notification.accepted = true;
                });
              },
              child: const Text('Accept'),
            ),
          ),
        );
      },
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late FirebaseMessaging messaging;
  String? notificationTitle;
  String? notificationBody;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    // iOS permission for notifications
    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // When the app is in the foreground and a notification is received
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        notificationTitle = message.notification?.title;
        notificationBody = message.notification?.body;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notificationTitle ?? 'No Title'),
          content: Text(notificationBody ?? 'No Body'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });

    // Handle when the app is opened from a background notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {
        notificationTitle = message.notification?.title;
        notificationBody = message.notification?.body;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Messaging Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Notification Title: $notificationTitle',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Notification Body: $notificationBody',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void initialize() {
    // Request permission for iOS devices
    _firebaseMessaging.requestPermission();

    // Listen for messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Handle notification message here (for example, show an alert or update UI)
        print('Notification received: ${message.notification!.title}');
      }
    });

    // Handle messages when the app is in the background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Handle when the user taps on a notification
        print('Notification tapped: ${message.notification!.title}');
      }
    });
  }
}

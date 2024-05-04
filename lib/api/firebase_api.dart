import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    try {
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      final prefs = await SharedPreferences.getInstance();
      if (fcmToken != null) {
        prefs.setString("fcmToken", fcmToken);
      }
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    } catch (err) {
      print(err);
    }
  }
}

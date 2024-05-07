import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:obsydia_copy_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Future<void> handleNotification(RemoteMessage message) async {}

Future initPushNotification() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}

void handleRouting(RemoteMessage? message) {
  if (message == null) return;
  navigatorKey.currentState?.pushNamed('/detail', arguments: message);
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    try {
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      print(fcmToken);
      final prefs = await SharedPreferences.getInstance();
      if (fcmToken != null) {
        prefs.setString("fcmToken", fcmToken);
      }
      // Background
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      // Foreground
      FirebaseMessaging.onMessage.listen(handleBackgroundMessage);
      // Terminated
      FirebaseMessaging.instance.getInitialMessage().then(handleRouting);
      // On tap
      FirebaseMessaging.onMessageOpenedApp.listen(handleRouting);
    } catch (err) {
      print(err);
    }
  }
}

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:obsydia_copy_1/api/firebase_api.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_bloc.dart';
import 'package:obsydia_copy_1/bloc/issue/issue_bloc.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_bloc.dart';
import 'package:obsydia_copy_1/firebase_options.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/pages/home_page.dart';
import 'package:obsydia_copy_1/pages/issue/issue_detail_page.dart';
import 'package:obsydia_copy_1/pages/login_page.dart';
import 'package:obsydia_copy_1/theme.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  if (notificationResponse.payload == null) {
    return;
  }
  Map<String, dynamic> payload = jsonDecode(notificationResponse.payload!);

  try {
    Map<String, dynamic> details =
        await IssueBloc().getIssueById(payload['issue_id']);
    navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => IssueDetailPage(
              issue: details["issue"],
              tenant: details['tenant'],
              activityId: payload["activity_id"],
            )));
  } catch (err) {
    print(err);
  }
}

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  //
  final localNotifications = FlutterLocalNotificationsPlugin();
  // Initialization
  const androidInit = AndroidInitializationSettings('@drawable/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  const androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: "Important notifications channel",
    importance: Importance.defaultImportance,
  );
  //
  await localNotifications.initialize(
    initSettings,
    onDidReceiveNotificationResponse: notificationTapBackground,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  final notification = message.data;
  localNotifications.show(
      notification.hashCode,
      notification['notification_title'],
      notification['notification_body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
            actions: [],
            androidChannel.id,
            androidChannel.name,
            channelDescription: androidChannel.description,
            importance: androidChannel.importance,
            icon: '@drawable/ic_launcher'),
      ),
      payload: jsonEncode(message.data));
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
      name: "mit.obsidia", options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final authBloc = AuthBloc();
  final tenantBloc = TenantBloc();
  Tenant? response;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        await authBloc.checkLogin();

        await tenantBloc.getTenant();
      } catch (err) {
        debugPrint(err.toString());
      }

      /// If check login has successfully done it's job, then remove the splash screen
      FlutterNativeSplash.remove();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthBloc>.value(
          value: authBloc,
        ),
        Provider<TenantBloc>.value(
          value: tenantBloc,
        )
      ],
      child: Portal(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Obsidia Copycat',
          theme: themeData,
          home: StreamBuilder(
            stream: authBloc.controller.stream,
            builder: (context, snapshot) {
              if (snapshot.data?.auth != null) {
                return const HomePage();
              }
              return const LoginPage();
            },
          ),
        ),
      ),
    );
  }
}

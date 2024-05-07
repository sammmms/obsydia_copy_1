import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    final notification = message.notification;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(notification!.title.toString()),
          Text(notification.body.toString()),
          Text(message.data.toString()),
        ],
      ),
    );
  }
}

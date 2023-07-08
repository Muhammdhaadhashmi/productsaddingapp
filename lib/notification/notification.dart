import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future sendPushMessage(String body, String title, String token) async {
    try {
      print('sending');
      final response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    'key= AAAAnkfrDN0:APA91bEQYzEe54ueUZC698TBoTxAwFxSg9oxMfjUSzrEM3Ko9ck31CmiOezx6Ki2Q8Nvq5O4LmpU7YWPeniOTFaS-R3gn6bgf6e03Zm11g0TndeXhDOUkGI3gps1i3EO-Dk-X9DW5dQl',
              },
              body: json.encode({
                "pirority": "high",
                "registration_ids": [
                  token,
                ],
                "notification": {
                  "body": body,
                  "title": title,
                  "android_channel_id": "flutterNotification",
                  "sound": false
                }
              }));
      print('sent ${response.statusCode}and ${response.request}');
    } catch (e) {
      print(e.toString());
    }
  }

///////////////////////////////////////////////////////////
  static void createanddisplaynotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "flutterNotification",
          "flutterNotificationchannel",
          importance: Importance.max,
          priority: Priority.high,
          // color: Colors.blue,
          colorized: true,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}

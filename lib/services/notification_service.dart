import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  NotificationService._();

  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();


  static Future<void> showReminder({
    required String title,
    required String body,
  }) async {


    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'mamacare_reminders',
      'MamaCare Reminders',
      channelDescription:
          'Pregnancy care reminders',

      importance: Importance.max,
      priority: Priority.high,

      styleInformation:
          BigTextStyleInformation(
            '',
            contentTitle:
              'MamaCare Reminder',
            summaryText:
              'Tap to view full reminder',
          ),

      actions:[
        AndroidNotificationAction(
          'view',
          'View Reminder',
        )
      ],

      playSound:true,
      enableVibration:true,
    );


    const NotificationDetails details =
        NotificationDetails(
          android: androidDetails,
        );


    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
      payload:'pregnancy_reminder',
    );
  }
}
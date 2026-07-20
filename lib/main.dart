import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    "Background notification clicked: ${notificationResponse.payload}",
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: androidInitializationSettings,
  );

  await NotificationService.flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint(
        "Foreground notification clicked: ${response.payload}",
      );
    },
    onDidReceiveBackgroundNotificationResponse:
        notificationTapBackground,
  );

  runApp(const MamaCareApp());
}
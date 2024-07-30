import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class CustomNotification {
  final int id;
  final String title;
  final String body;
  final String? payload;

  CustomNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });
}

class NotificationService {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AndroidNotificationDetails androidDetails;
  late DarwinNotificationDetails iosDetails; // Usando DarwinNotificationDetails


  NotificationService() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _setupAndroidDetails();
    _setupIOSDetails();
    _setupNotifications();
  }

  void _setupAndroidDetails() {
    androidDetails = const AndroidNotificationDetails(
      'lembretes_notifications_details',
      'Insulina',
      channelDescription: 'Hora da insulina',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
    );
  }

  void _setupIOSDetails() {
    iosDetails = const DarwinNotificationDetails( // Usando DarwinNotificationDetails
      sound: 'default', // Som de notificação padrão
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
  }



  Future<void> _setupNotifications() async {
    await _setupTimezone();
    await _initializeNotifications();
  }

  Future<void> _setupTimezone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração específica para iOS
    final DarwinInitializationSettings ios = DarwinInitializationSettings(); // Usando DarwinInitializationSettings

  

    // Inicialização com suporte para Android, iOS e macOS
    final initializationSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await localNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: _onSelectNotification,
    );
  }

  Future<void> _onSelectNotification(String? payload) async {
    if (payload != null && payload.isNotEmpty) {
      // Implemente a navegação com base no payload da notificação
      // Exemplo: Navigator.of(context).pushNamed(payload);
    }
  }

  Future<void> showNotification(CustomNotification notification) async {
    await localNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        // Adicione detalhes para outras plataformas aqui
      ),
      payload: notification.payload,
    );
  }

  Future<void> checkForNotifications() async {
    final details =
        await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
     //  await _onSelectNotification(details.payload);
    }
  }
}

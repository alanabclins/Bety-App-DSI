import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificacaoScreen extends StatefulWidget {
  @override
  _NotificacaoScreenState createState() => _NotificacaoScreenState();
}

class _NotificacaoScreenState extends State<NotificacaoScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotification();
  }

  Future<void> _initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification() async {
    tz.initializeTimeZones(); // Inicializa as timezones
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // id
      'Título da Notificação', // título
      'Corpo da Notificação', // corpo
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)), // horário
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true, // Permite que a notificação apareça mesmo que o dispositivo esteja inativo
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notificações"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _scheduleNotification,
          child: Text('Agendar Notificação'),
        ),
      ),
    );
  }
}

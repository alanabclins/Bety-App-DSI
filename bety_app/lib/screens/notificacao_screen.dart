import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';

class NotificacaoScreen extends StatefulWidget {
  @override
  _NotificacaoScreenState createState() => _NotificacaoScreenState();
}

class _NotificacaoScreenState extends State<NotificacaoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  @override
  void initState() {
    super.initState();
    _configureFirebaseListeners();
  }

  void _configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.notification?.title ?? 'Nova notificação')),
      );
    });
  }

  Future<void> _sendNotification(String title, String body) async {
    await _firebaseMessaging.subscribeToTopic('refeicoes');
    await _firestore.collection('notificacoes').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteNotification(String notificationId) async {
    await _firestore.collection('notificacoes').doc(notificationId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Notificações',
        subtitle: 'Se atente às suas notificações!',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('notificacoes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar notificações'));
          }

          final notificacoes = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notificacoes.length,
            itemBuilder: (context, index) {
              final notificacao = notificacoes[index];
              return Card(
                color: Color.fromARGB(255, 199, 244, 194),
                child: ListTile(
                  title: Text(notificacao['title']),
                  subtitle: Text(notificacao['body']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteNotification(notificacao.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _sendNotification(
            'Hora de Refeição',
            'Está na hora de tomar sua refeição programada!',
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF0BAB7C),
      ),
    );
  }
}

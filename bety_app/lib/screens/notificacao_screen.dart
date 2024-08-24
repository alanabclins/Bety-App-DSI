import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../notification_service.dart';
import 'package:provider/provider.dart';

class NotificacaoScreen extends StatefulWidget {
  @override
  _NotificacaoScreenState createState() => _NotificacaoScreenState();
}

class _NotificacaoScreenState extends State<NotificacaoScreen> {
  bool valor = false; // Variável para controlar botao
  void showNotificatio() {
  setState(() {
    valor = !valor;
    if (valor) {
     final notificacao = new NotificationService();
     final custom = new CustomNotification(id:1, title: "a", body: "aaa", payload: "/");
     notificacao.showNotification(custom);
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notificações',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0BAB7C),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Voltar pra tela anterior
          },
        ),
      ),
<<<<<<< HEAD
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Color.fromARGB(255, 199, 244, 194),
              child: ListTile(
                title: Text('Se atente ao tomar o remédio X'),
              ),
            ),
            Card(
              color: Color.fromARGB(255, 199, 244, 194),
              child: ListTile(
                title: Text('Está na hora de aplicar sua insulina'),
              ),
            ),
            Card(
              color: Color.fromARGB(255, 199, 244, 194),
              child: ListTile(
                title: Text('Já chegou seu nível de glicose?'),
              ),
            ),
            Card(
              color: Color.fromARGB(255, 199, 244, 194),
              child: ListTile(
                title: Text('Está na hora de tomar o remédio X'),
              ),
            ),
            SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () {
<<<<<<< HEAD
                setState(() {
                  valor = !valor; // Alternar o valor do checkbox
                });
=======
                // Ação do botão
                Navigator.pop(
                    context); // Exemplo de ação: voltar à tela anterior
>>>>>>> main
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0BAB7C), // Cor do botão
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: ListTile(
              title: const Text('Lembrar-me mais tarde'),
              trailing: valor
                  ? Icon(Icons.check_box, color: Colors.amber.shade600)
                  : const Icon(Icons.check_box_outline_blank),
              onTap: showNotificatio,
              ),
            ),
          ],
        ),
=======
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
>>>>>>> main
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../notification_service.dart';
import 'package:provider/provider.dart';

class NotificacaoScreen extends StatefulWidget {
  @override
  _NotificacaoScreenState createState() => _NotificacaoScreenState();
}

class _NotificacaoScreenState extends State<NotificacaoScreen> {
  bool valor = false; // Variável para controlar botao
  void showNotification() {
  setState(() {
    valor = !valor;
    if (valor) {
      Provider.of<NotificationService>(context, listen: false).showNotification(
        CustomNotification(
          id: 1,
          title: 'Teste',
          body: 'Acesse o app!',
          payload: '',
        ),
      );
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
                setState(() {
                  valor = !valor; // Alternar o valor do checkbox
                });
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
              onTap: showNotification,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

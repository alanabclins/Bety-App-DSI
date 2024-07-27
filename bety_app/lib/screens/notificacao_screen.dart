import 'package:flutter/material.dart';

class NotificacaoScreen extends StatelessWidget {
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
            // Navegue de volta à tela inicial aqui
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
            SizedBox(height: 20), // Espaço antes do botão
            ElevatedButton(
              onPressed: () {
                // Ação do botão
                Navigator.pop(context); // Exemplo de ação: voltar à tela anterior
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0BAB7C), // Cor do botão
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Voltar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

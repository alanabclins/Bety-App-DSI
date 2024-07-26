import 'package:flutter/material.dart';

class NotificacaoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
        backgroundColor: Color.fromARGB(255, 11, 171, 124),
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
            // Exemplos de balões de notificação aqui
            Card(
              color: Colors.green,
              child: ListTile(
                title: Text('Lembre-se de tomar o medicamento X'),
              ),
            ),
            Card(
              color: Colors.green,
              child: ListTile(
                title: Text('Verifique seus níveis de glicose'),
              ),
            ),
            // Mais exemplos de notificações
          ],
        ),
      ),
    );
  }
}

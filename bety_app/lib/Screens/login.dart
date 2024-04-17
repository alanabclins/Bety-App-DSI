import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100.0,
              height: 100.0,
              color: const Color.fromARGB(255, 76, 136, 78), // Substitua isso pelo seu logotipo
            ),
            const SizedBox(height: 50.0),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.lightGreen[100],
                hintText: 'Digite seu e-mail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.lightGreen[100],
                hintText: 'Digite sua senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 70, 134, 72), // Cor do botão
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {}, // Adicione a função de login aqui
              child: const Text('entrar'),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed:
                  () {}, // Adicione a função de navegação para a tela de registro aqui
              child: const Text('para se cadastrar, clique aqui!'),
            ),
          ],
        ),
      ),
    );
  }
}
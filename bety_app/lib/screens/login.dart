import 'package:bety_app/screens/cadastro_screen.dart';
import 'package:flutter/material.dart';
import 'package:bety_app/screens/home.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100.0,
                height: 100.0,
                color: const Color.fromARGB(255, 76, 136, 78), // Substitua isso pelo seu logotipo
              ),
              const SizedBox(height: 50.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.lightGreen[100],
                  hintText: 'Digite seu e-mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.lightGreen[100],
                  hintText: 'Digite sua senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 70, 134, 72), // Cor do botão
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage2()));
                  if (_formKey.currentState!.validate()) {
                    // Adicione a função de login aqui
                  }
                },
                child: const Text('entrar'),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed:
                    () { Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroScreen()));}, // Adicione a função de navegação para a tela de registro aqui
                child: const Text('para se cadastrar, clique aqui!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

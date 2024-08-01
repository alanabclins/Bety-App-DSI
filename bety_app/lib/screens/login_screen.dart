import 'package:bety_sprint1/screens/cadastro_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bety_sprint1/services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 251, 250, 243),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              "assets/betyLogo.png",
              width: 120,
              height: 120,
            ),
            const Text(
              "Bety",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 11, 171, 124),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Seu email aqui",
                        filled: true,
                        fillColor: const Color.fromARGB(255, 199, 244, 194),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 35),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      obscuringCharacter: "*",
                      controller: _senhaController,
                      decoration: InputDecoration(
                        labelText: "Sua senha aqui",
                        suffixIconColor:
                            const Color.fromARGB(255, 11, 171, 124),
                        suffixIcon: const Icon(Icons.remove_red_eye),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 199, 244, 194),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String? result = await _authService.entrarUsuario(
                              email: _emailController.text,
                              senha: _senhaController.text,
                            );

                            if (result == null) {
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreen(user: user),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erro ao obter usuário'),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro: $result'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          textStyle: const TextStyle(fontSize: 20),
                          foregroundColor:
                              const Color.fromARGB(255, 199, 244, 194),
                          backgroundColor:
                              const Color.fromARGB(255, 11, 171, 124),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CadastroScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "para se cadastrar clique aqui",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color.fromARGB(255, 11, 171, 124),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
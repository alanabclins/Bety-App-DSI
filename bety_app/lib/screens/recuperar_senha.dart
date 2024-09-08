import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:flutter/material.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  @override
  _RecuperarSenhaScreenState createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Recuperar senha',
        subtitle: 'Digite!',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Informe o seu email para recuperar a senha",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await AuthService().redefinicaoSenha(
                      email: _emailController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Um link para redefinir sua senha foi enviado ao seu email.',
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  textStyle: const TextStyle(fontSize: 20),
                  foregroundColor: const Color.fromARGB(255, 199, 244, 194),
                  backgroundColor: const Color.fromARGB(255, 11, 171, 124),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

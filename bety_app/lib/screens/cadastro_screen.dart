import 'package:flutter/material.dart';
import 'package:bety_app/screens/home.dart';

void main() {
  runApp(const MaterialApp(
    home: CadastroScreen(),
  ));
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  String? _tipoUsuario;
  DateTime? _dataNascimento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bety'),
        backgroundColor: Colors.green[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.lightGreen[100],
                  hintText: 'Digite seu nome completo',
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
              const SizedBox(height: 10.0),
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
                  if (!value.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.lightGreen[100],
                  hintText: 'Data de nascimento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  try {
                    final date = DateTime.parse(value);
                    if (date.year >= 2024) {
                      return 'Data de nascimento inválida';
                    }
                  } catch (e) {
                    return 'Formato de data inválido';
                  }
                  return null;
                },
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2023),
                  );
                  if (date != null) {
                    setState(() {
                      _dataNascimento = date;
                    });
                  }
                },
                readOnly: false,
                controller: TextEditingController(
                  text: _dataNascimento != null
                      ? '${_dataNascimento!.day}/${_dataNascimento!.month}/${_dataNascimento!.year}'
                      : '',
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _senhaController,
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
                  if (_confirmarSenhaController.text != value) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _confirmarSenhaController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.lightGreen[100],
                  hintText: 'Confirme sua senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (_senhaController.text != value) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 10.0),
              CheckboxListTile(
                title: const Text('Sou cuidador'),
                value: _tipoUsuario == 'cuidador',
                onChanged: (value) {
                  setState(() {
                    _tipoUsuario = value! ? 'cuidador' : 'paciente';
                  });
                },
              ),Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    ),
                    onPressed: () {
                    if (_formKey.currentState!.validate()) {
                        // Formulário validado com sucesso, continuar com o registro
                        _mostrarDialogoSucesso();
                    }
                    },
                    child: const Text('Finalizar cadastro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   void _mostrarDialogoSucesso() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sucesso!'),
          content: const Text('Sua conta foi ativada com sucesso.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage2()));;
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

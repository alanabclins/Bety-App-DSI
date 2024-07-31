import 'package:bety_sprint1/services/auth_service.dart';
import 'package:flutter/material.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController =
      TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  final TextEditingController _tipoDiabetesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPaciente = false;
  bool _isCuidador = false;

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: const Color.fromARGB(255, 11, 171, 124),
      ),
      body: Container(
        color: const Color.fromARGB(255, 251, 250, 243),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: "Seu nome",
                    filled: true,
                    fillColor: const Color.fromARGB(255, 199, 244, 194),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Seu email",
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
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  obscuringCharacter: "*",
                  controller: _senhaController,
                  decoration: InputDecoration(
                    labelText: "Sua senha",
                    suffixIconColor: const Color.fromARGB(255, 11, 171, 124),
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
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  obscuringCharacter: "*",
                  controller: _confirmaSenhaController,
                  decoration: InputDecoration(
                    labelText: "Confirme sua senha",
                    suffixIconColor: const Color.fromARGB(255, 11, 171, 124),
                    suffixIcon: const Icon(Icons.remove_red_eye),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 199, 244, 194),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua senha';
                    }
                    if (value != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dataNascimentoController,
                  decoration: InputDecoration(
                    labelText: "Data de Nascimento",
                    filled: true,
                    fillColor: const Color.fromARGB(255, 199, 244, 194),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua data de nascimento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _tipoDiabetesController,
                  decoration: InputDecoration(
                    labelText: "Tipo de Diabetes",
                    filled: true,
                    fillColor: const Color.fromARGB(255, 199, 244, 194),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o tipo de diabetes';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  title: const Text("Paciente"),
                  value: _isPaciente,
                  onChanged: (value) {
                    setState(() {
                      _isPaciente = value ?? false;
                      if (_isPaciente) {
                        _isCuidador = false;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("Cuidador"),
                  value: _isCuidador,
                  onChanged: (value) {
                    setState(() {
                      _isCuidador = value ?? false;
                      if (_isCuidador) {
                        _isPaciente = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String? result = await _authService.cadastrarUsuario(
                          email: _emailController.text,
                          senha: _senhaController.text,
                          nome: _nomeController.text,
                          dataNascimento: _dataNascimentoController.text,
                          tipoDiabetes: _tipoDiabetesController.text,
                          isPaciente: _isPaciente,
                        );

                        if (result == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cadastro realizado com sucesso'),
                            ),
                          );
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
                      foregroundColor: const Color.fromARGB(255, 199, 244, 194),
                      backgroundColor: const Color.fromARGB(255, 11, 171, 124),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/session_service.dart';
import '../utils/custom_app_bar.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascimentoController = TextEditingController();
  final TextEditingController _tipoDiabetesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSenhaVisible = false;
  bool _isConfirmaSenhaVisible = false;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1904),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dataNascimentoController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Criação das instâncias dos serviços
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Cadastro',
        subtitle: 'Faça o seu cadastro!',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
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
                _buildNomeField(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildSenhaField(),
                const SizedBox(height: 20),
                _buildConfirmaSenhaField(),
                const SizedBox(height: 20),
                _buildDataNascimentoField(),
                const SizedBox(height: 20),
                _buildTipoDiabetesField(),
                const SizedBox(height: 35),
                _buildCadastrarButton(authService),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Campos do Formulário
  Widget _buildNomeField() {
    return TextFormField(
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
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
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
    );
  }

  Widget _buildSenhaField() {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      obscureText: !_isSenhaVisible,
      obscuringCharacter: "*",
      controller: _senhaController,
      decoration: InputDecoration(
        labelText: "Sua senha",
        suffixIconColor: const Color.fromARGB(255, 11, 171, 124),
        suffixIcon: IconButton(
          icon: Icon(
            _isSenhaVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isSenhaVisible = !_isSenhaVisible;
            });
          },
        ),
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
    );
  }

  Widget _buildConfirmaSenhaField() {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      obscureText: !_isConfirmaSenhaVisible,
      obscuringCharacter: "*",
      controller: _confirmaSenhaController,
      decoration: InputDecoration(
        labelText: "Confirme sua senha",
        suffixIconColor: const Color.fromARGB(255, 11, 171, 124),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmaSenhaVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isConfirmaSenhaVisible = !_isConfirmaSenhaVisible;
            });
          },
        ),
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
    );
  }

  Widget _buildDataNascimentoField() {
    return TextFormField(
      controller: _dataNascimentoController,
      decoration: InputDecoration(
        labelText: 'Data de nascimento',
        filled: true,
        fillColor: const Color.fromARGB(255, 199, 244, 194),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            _selectDate(context);
          },
        ),
      ),
      readOnly: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira a data de nascimento';
        }
        return null;
      },
    );
  }

  Widget _buildTipoDiabetesField() {
    return TextFormField(
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
    );
  }

  Widget _buildCadastrarButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              _isLoading = true;
            });

            // Utilizando a função signUp do AuthService
            try {
              await authService.signUp(
                email: _emailController.text,
                password: _senhaController.text,
                nome: _nomeController.text,
                tipoDeDiabetes: _tipoDiabetesController.text,
                dataDeNascimento: DateFormat('dd/MM/yyyy').parse(_dataNascimentoController.text),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cadastro realizado com sucesso')),
              );

              // Navegar para outra tela ou realizar alguma ação após o cadastro
              Navigator.pop(context);

            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao cadastrar usuário: $e')),
              );
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Cadastrar'),
      ),
    );
  }
}
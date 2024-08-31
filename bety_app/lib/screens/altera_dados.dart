import 'package:flutter/material.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:bety_sprint1/utils/alert_dialog.dart';
import 'package:bety_sprint1/screens/adicionar_refeicao_screen.dart';
import 'package:bety_sprint1/services/refeicao.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/services/user.dart';

class DadosCadastraisScreen extends StatefulWidget {

  DadosCadastraisScreen();

  @override
  _DadosCadastraisScreenState createState() => _DadosCadastraisScreenState();
}

class _DadosCadastraisScreenState extends State<DadosCadastraisScreen> {
  late TextEditingController _nomeController;
  late TextEditingController _tipoDiabetesController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _emailController;
  late Stream<List<Refeicao>> _refeicoesStream;
  final RefeicaoService _refeicaoService = RefeicaoService();
  final SessionManager _sessionManager = SessionManager();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    final currentUser = _sessionManager.currentUser;
    if (currentUser != null) {
      _nomeController = TextEditingController(text: currentUser.nome);
      _tipoDiabetesController = TextEditingController(text: currentUser.tipoDeDiabetes);
      _dataNascimentoController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(currentUser.dataDeNascimento)
      );
      _emailController = TextEditingController(text: currentUser.email);

      _refeicoesStream = _refeicaoService.getRefeicoesPorUsuario(currentUser.uid);
    } else {
      print('Usuário não está logado.');
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoDiabetesController.dispose();
    _dataNascimentoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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

  Future<void> _saveData() async {
    final currentUser = _sessionManager.currentUser;

    if (currentUser == null) {
      print('Erro: Usuário não está logado.');
      return;
    }

    try {
      // Atualize os campos do usuário com os dados dos controladores
      final updatedUser = User(
        uid: currentUser.uid,
        email: currentUser.email,
        nome: _nomeController.text,
        tipoDeDiabetes: _tipoDiabetesController.text,
        dataDeNascimento: DateFormat('dd/MM/yyyy').parse(_dataNascimentoController.text),
        fotoPerfilUrl: currentUser.fotoPerfilUrl, // Mantém a foto de perfil existente
      );

      // Atualiza o usuário no Firestore
      await _userService.updateUserData(updatedUser);
      await _authService.updateUserInSession();
    } catch (e) {
      print('Erro ao salvar dados: $e');
    }
  }

  void _handleButtonPress() async {
    final currentUser = _sessionManager.currentUser;
    final email = currentUser?.email;
    final newEmail = _emailController.text.trim();

    if (email != newEmail) {
      await _saveData();

      try {
        await _authService.updateEmail(newEmail);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verifique seu e-mail para confirmar a alteração.'),
            duration: Duration(seconds: 3),
          ),
        );

        await _authService.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        print('Erro ao enviar e-mail de verificação: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar e-mail.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      await _saveData();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFBFAF3),
      appBar: CustomAppBar(
        mainTitle: 'Perfil',
        subtitle: 'Modifique suas informações pessoais',
        showLogoutButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Seu nome',
                filled: true,
                fillColor: const Color.fromARGB(255, 199, 244, 194),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tipoDiabetesController,
              decoration: InputDecoration(
                labelText: 'Tipo de diabetes',
                filled: true,
                fillColor: const Color.fromARGB(255, 199, 244, 194),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
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
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: const Color.fromARGB(255, 199, 244, 194),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: StreamBuilder<List<Refeicao>>(
                stream: _refeicoesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar refeições'));
                  }

                  final refeicoes = snapshot.data ?? [];
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                    ),
                    items: [
                      ...refeicoes.map((refeicao) {
                        final hora = refeicao.hora;
                        final horaDateTime = hora.toDate();
                        final horaFormatada = DateFormat('HH:mm').format(horaDateTime);

                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: 200.0,
                              child: Card(
                                color: Color(0xFF0BAB7C),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 18.0),
                                          Text(
                                            refeicao.descricao,
                                            style: TextStyle(fontSize: 20.0, color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 10.0),
                                          Text(
                                            horaFormatada,
                                            style: TextStyle(fontSize: 18.0, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: IconButton(
                                        icon: Icon(Icons.edit, color: Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdicionarRefeicaoScreen(
                                                refeicao: refeicao,
                                              ),
                                            ),
                                          ).then((_) {
                                            setState(() {
                                              _refeicoesStream = _refeicaoService.getRefeicoesPorUsuario(_sessionManager.currentUser!.uid);
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                      Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: 300.0,
                            child: Card(
                              color: Color(0xFF0BAB7C),
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdicionarRefeicaoScreen(), // Substitua por sua tela de destino
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 50.0, color: Colors.white),
                                    SizedBox(height: 10.0),
                                    Text(
                                      'Adicionar nova refeição',
                                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            FractionallySizedBox(
              widthFactor: 0.9, // 90% da largura disponível
              child: SizedBox(
                height: 50, // Altura constante
                child: ElevatedButton(
                  onPressed: () {
                    CustomAlertDialog.show(
                      context: context,
                      title: 'Salvar alterações',
                      content: 'Você tem certeza que deseja salvar as alterações?',
                      onConfirm: () {
                        _handleButtonPress();
                      },
                    );
                  },
                  child: Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BAB7C),
                    foregroundColor: Color(0xFFFBFAF3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10), // Espaço entre os botões
            FractionallySizedBox(
              widthFactor: 0.9, // 90% da largura disponível
              child: SizedBox(
                height: 50, // Altura constante
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Color(0xFFFBFAF3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
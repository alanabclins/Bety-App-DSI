import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bety_sprint1/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DadosCadastraisScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userData;

  DadosCadastraisScreen({required this.user, required this.userData});

  @override
  _DadosCadastraisScreenState createState() => _DadosCadastraisScreenState();
}

class _DadosCadastraisScreenState extends State<DadosCadastraisScreen> {
  late TextEditingController _nomeController;
  late TextEditingController _tipoDiabetesController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _emailController;
  late Future<List<Map<String, dynamic>>> _refeicoesFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.userData['nome']);
    _tipoDiabetesController = TextEditingController(text: widget.userData['tipoDiabetes']);
    _dataNascimentoController = TextEditingController(text: widget.userData['dataNascimento']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _refeicoesFuture = _authService.obterRefeicoes(widget.user.uid);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoDiabetesController.dispose();
    _dataNascimentoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(widget.user.uid).update({
        'nome': _nomeController.text,
        'tipoDiabetes': _tipoDiabetesController.text,
        'dataNascimento': _dataNascimentoController.text,
      });
    } catch (e) {
      print('Erro ao salvar dados: $e');
    }
  }

  void _handleButtonPress() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final email = currentUser?.email;
    final newEmail = _emailController.text.trim();
    if (email != newEmail) {
      await _saveData();
      try {
        String? emailUpdateError = await _authService.atualizarEmail(newEmail);
        if (emailUpdateError != null) {
          print('Erro ao atualizar email: $emailUpdateError');
        } else {
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verifique seu email antes do próximo login para que seja alterado'),
              duration: Duration(seconds: 3),
            ),
          );
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        }
      } catch (e) {
        print('Erro ao enviar email de verificação: $e');
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

  void _addNewRefeicao() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController descricaoController = TextEditingController();
        TimeOfDay? selectedTime;

        Future<void> _selectTime(BuildContext context) async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
          );
          if (picked != null && picked != selectedTime) {
            setState(() {
              selectedTime = picked;
            });
          }
        }

        return AlertDialog(
          title: Text('Adicionar Nova Refeição'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
              SizedBox(height: 10),
              Text(
                selectedTime != null
                    ? 'Hora selecionada: ${selectedTime!.format(context)}'
                    : 'Nenhuma hora selecionada',
              ),
              TextButton(
                onPressed: () => _selectTime(context),
                child: Text('Escolher Hora'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedTime != null) {
                  final now = DateTime.now();
                  final DateTime hora = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  await _authService.registrarRefeicao(
                    userId: widget.user.uid,
                    hora: hora,
                    descricao: descricaoController.text,
                  );
                  setState(() {
                    _refeicoesFuture = _authService.obterRefeicoes(widget.user.uid);
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, selecione uma hora')),
                  );
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
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
              decoration: InputDecoration(labelText: 'Seu nome'),
            ),
            TextField(
              controller: _tipoDiabetesController,
              decoration: InputDecoration(labelText: 'Tipo de diabetes'),
            ),
            TextField(
              controller: _dataNascimentoController,
              decoration: InputDecoration(labelText: 'Data de nascimento'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _refeicoesFuture,
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
                      aspectRatio: 16/9, // Ajuste conforme necessário
                      viewportFraction: 0.8, // Ajusta o tamanho do card
                    ),
                    items: [
                      ...refeicoes.map((refeicao) {
                        final hora = (refeicao['hora'] as Timestamp).toDate();
                        final horaFormatada = DateFormat('HH:mm').format(hora);

                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: 200.0, // Define a largura fixa do card
                              child: Card(
                                color: Color(0xFF0BAB7C), // Define a cor de fundo do card
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 18.0),
                                    Text(
                                      refeicao['descricao'] ?? 'Sem descrição',
                                      style: TextStyle(fontSize: 20.0, color: Colors.white), // Texto branco
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      horaFormatada,
                                      style: TextStyle(fontSize: 18.0, color: Colors.white), // Texto branco
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
                            width: 300.0, // Define a largura fixa do card
                            child: Card(
                              color: Color(0xFF0BAB7C), // Define a cor de fundo do card
                              child: InkWell(
                                onTap: _addNewRefeicao,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 50.0, color: Colors.white), // Ícone branco
                                    SizedBox(height: 10.0),
                                    Text(
                                      'Adicionar nova refeição',
                                      style: TextStyle(fontSize: 18.0, color: Colors.white), // Texto branco
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
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _handleButtonPress,
                  child: Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BAB7C),
                    foregroundColor: Color(0xFFFBFAF3),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Color(0xFFFBFAF3),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
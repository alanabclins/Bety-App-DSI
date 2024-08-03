import 'package:flutter/material.dart';
import 'package:bety_sprint1/screens/altera_dados.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';

class PonteAttDados extends StatelessWidget {
  final User user;
  final Map<String, dynamic> userData;

  PonteAttDados({required this.user, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBFAF3),
      appBar: CustomAppBar(
        showLogoutButton: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DadosCadastraisScreen(user: user, userData: userData),
                    ),
                  );
                },
                child: Text('Dados cadastrais'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BAB7C),
                  foregroundColor: Color(0xFFFBFAF3),
                  padding: EdgeInsets.all(25), // Aumentar tamanho do botão
                  minimumSize: Size(200, 60), // Definir tamanho mínimo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navegar para Refeições
                },
                child: Text('Refeições'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BAB7C),
                  foregroundColor: Color(0xFFFBFAF3),
                  padding: EdgeInsets.all(25), // Aumentar tamanho do botão
                  minimumSize: Size(200, 60), // Definir tamanho mínimo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Voltar para a tela anterior
                },
                child: Text('Cancelar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Color(0xFFFBFAF3),
                  padding: EdgeInsets.all(25), // Aumentar tamanho do botão
                  minimumSize: Size(200, 60), // Definir tamanho mínimo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

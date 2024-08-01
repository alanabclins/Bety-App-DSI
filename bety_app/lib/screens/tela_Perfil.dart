import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'dart:io';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Perfil',
        subtitle: 'Configure seu perfil',
        showLogoutButton: true,
        onBackButtonPressed: () {
          // Implementar ação para voltar
        },
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('usuarios').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Nenhum dado encontrado'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userData['profile_image_url'] ?? 'https://example.com/default.jpg'),
              ),
              SizedBox(height: 20),
              Text(
                'Informações pessoais',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFC7F4C2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileDetailRow(
                      label: 'Seu nome:',
                      value: userData['nome'] ?? 'Nome não disponível',
                    ),
                    ProfileDetailRow(
                      label: 'Tipo de diabetes:',
                      value: userData['tipoDiabetes'] ?? 'Tipo não disponível',
                    ),
                    ProfileDetailRow(
                      label: 'Data de nascimento:',
                      value: userData['dataNascimento'] ?? 'Data não disponível',
                    ),
                    ProfileDetailRow(
                      label: 'Email:',
                      value: userData['email'] ?? 'Email não disponível',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Ação para alterar informações
                },
                child: Text('Alterar informações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BAB7C),
                  foregroundColor: Color(0xFFFBFAF3),
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  ProfileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }
}
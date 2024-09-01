import 'package:bety_sprint1/screens/altera_dados.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/models/user.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen();

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _updateProfileImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolha a fonte da imagem'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Text('Câmera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Text('Galeria'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final user = SessionManager().currentUser;

        if (user != null) {
          final downloadUrl = await UserService().updateProfilePicture(user.uid, file.path);

          if (downloadUrl != null) {
            setState(() {
              user.fotoPerfilUrl = downloadUrl;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao fazer upload da imagem')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionManager().currentUser;

    if (user == null) {
      return Center(child: Text('Nenhum usuário encontrado'));
    }

    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Perfil',
        subtitle: 'Configure seu perfil',
        showLogoutButton: true,
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(user.fotoPerfilUrl ??
                'https://example.com/default.jpg'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateProfileImage,
            child: Text('Atualizar foto de perfil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0BAB7C),
              foregroundColor: Color(0xFFFBFAF3),
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
                  value: user.nome,
                ),
                ProfileDetailRow(
                  label: 'Tipo de diabetes:',
                  value: user.tipoDeDiabetes,
                ),
                ProfileDetailRow(
                  label: 'Data de nascimento:',
                  value: DateFormat('dd/MM/yyyy').format(user.dataDeNascimento),
                ),
                ProfileDetailRow(
                  label: 'Email:',
                  value: user.email,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DadosCadastraisScreen(),
                ),
              );
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
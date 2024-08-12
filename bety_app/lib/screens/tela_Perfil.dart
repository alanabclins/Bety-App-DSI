import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/screens/ponte_att_dados.dart';
import 'package:path/path.dart' as path;

class ProfileScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userData;

  const ProfileScreen({super.key, required this.user, required this.userData});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> _updateProfileImage() async {
    // Exibe um diálogo para o usuário escolher entre a câmera e a galeria
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
        final userId = widget.user.uid;
        final storageService = StorageService();

        // Upload da imagem e obtenção da URL
        final downloadUrl = await storageService.uploadProfilePicture(file, userId);

        if (downloadUrl != null) {
          // Atualizar a URL no Firestore
          await _firestore.collection('usuarios').doc(userId).update({
            'profile_image_url': downloadUrl,
          });
          setState(() {
            widget.userData['profile_image_url'] = downloadUrl;
          });
        } else {
          // Handle upload error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao fazer upload da imagem')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Perfil',
        subtitle: 'Configure seu perfil',
        showLogoutButton: true,
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('usuarios').doc(widget.user.uid).get(),
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

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onLongPress: _updateProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userData['profile_image_url'] ??
                      'https://example.com/default.jpg'),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PonteAttDados(user: widget.user, userData: userData),
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

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfilePicture(File file, String userId) async {
    try {
      final fileName = path.basename(file.path);
      final ref = _storage.ref().child('profile_pictures/$userId/$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }
}
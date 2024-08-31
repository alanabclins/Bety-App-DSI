import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'dart:io';

class User {
  final DocumentReference uid;
  final String email;
  final String nome;
  final String tipoDeDiabetes;
  final DateTime dataDeNascimento;
  final String? fotoPerfilUrl;

  User({
    required this.uid,
    required this.email,
    required this.nome,
    required this.tipoDeDiabetes,
    required this.dataDeNascimento,
    this.fotoPerfilUrl,
  });

  // Método para criar um objeto User a partir de um JSON (mapa)
  factory User.fromJson(DocumentReference uid, Map<String, dynamic> json) {
    return User(
      uid: uid,
      email: json['email'],
      nome: json['nome'],
      tipoDeDiabetes: json['tipoDeDiabetes'],
      dataDeNascimento: (json['dataDeNascimento'] as Timestamp).toDate(),
      fotoPerfilUrl: json['fotoPerfilUrl'],
    );
  }

  // Método para converter o objeto User em um JSON (mapa)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nome': nome,
      'tipoDeDiabetes': tipoDeDiabetes,
      'dataDeNascimento': Timestamp.fromDate(dataDeNascimento), // Converte DateTime para Timestamp
      'fotoPerfilUrl': fotoPerfilUrl,
    };
  }
}


class UserService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Criar ou atualizar um documento do usuário no Firestore
  Future<void> saveUser(User user) async {
    await user.uid.set(user.toJson());
  }

  // Buscar os dados do usuário a partir do DocumentReference e converter com `fromJson`
  Future<User?> getUser(DocumentReference uid) async {
    try {
      DocumentSnapshot doc = await uid.get();
      if (doc.exists) {
        // Converte o Map<String, dynamic> para um objeto User usando fromJson
        return User.fromJson(uid, doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
    }
    return null;
  }

  // Atualizar a foto de perfil do usuário
  Future<String?> updateProfilePicture(DocumentReference uid, String filePath) async {
    try {
      // Upload da imagem para o Firebase Storage
      Reference ref = _storage.ref().child('profilePictures/${uid.id}.jpg');
      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot snapshot = await uploadTask;

      // Obter a URL da imagem armazenada
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Atualizar o campo fotoPerfilUrl no Firestore
      await uid.update({
        'fotoPerfilUrl': downloadUrl,
      });
      await AuthService().updateUserInSession();

      return downloadUrl;
    } catch (e) {
      print('Erro ao atualizar foto de perfil: $e');
      return null;
    }
  }

    Future<void> updateUserData(User user) async {
    try {
      // Atualiza o documento do usuário com os dados do objeto User
      await user.uid.update(user.toJson());
      await AuthService().updateUserInSession();
    } catch (e) {
      print('Erro ao atualizar dados do usuário: $e');
    }
  }
}
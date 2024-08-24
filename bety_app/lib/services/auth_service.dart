import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_email_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
//import 'package:intl/intl.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthEmailService _authEmailService = AuthEmailService();

  // Função de autenticação
  Future<String?> entrarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: senha);
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('usuarios').doc(user.uid).update({
          'email': user.email,
        });
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'wrong-password':
          return 'Senha incorreta';
      }
      return e.code;
    }
    return null;
  }

  // Função para atualizar o email
  Future<String?> atualizarEmail(String novoEmail) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return 'Nenhum usuário autenticado.';
    }

    try {
      // Utilize a função verifyBeforeUpdateEmail para atualizar o email no Firebase Authentication
      await _authEmailService.verifyBeforeUpdateEmail(novoEmail);

      // Recarregue o usuário para garantir que o novo email esteja atualizado
      await user.reload();
      User? updatedUser = _firebaseAuth.currentUser;

      if (updatedUser != null) {
        print('Email atualizado com sucesso');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          return 'É necessário reautenticar o usuário para atualizar o email.';
        case 'invalid-email':
          return 'O email fornecido é inválido.';
        case 'email-already-in-use':
          return 'O email já está em uso por outra conta.';
        case 'user-not-found':
          return 'Usuário não encontrado.';
        default:
          return e.code;
      }
    } catch (e) {
      print('Erro ao atualizar o email: $e');
      return 'Erro ao atualizar o email.';
    }
    return null;
  }

  // Função de cadastro
  Future<String?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String dataNascimento,
    required String tipoDiabetes,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);

      await userCredential.user!.updateDisplayName(nome);

      // Armazena os dados adicionais no Firestore
      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nome': nome,
        'email': email,
        'dataNascimento': dataNascimento,
        'tipoDiabetes': tipoDiabetes,
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'O email já está em uso.';
      }
      return e.code;
    }
    return null;
  }

  // Função de redefinir senha
  Future<String?> redefinicaoSenha({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
      }
      return e.code;
    }
    return null;
  }

  // Função de deslogar
  Future<String?> deslogar() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  // Função de excluir conta
  Future<String?> excluirConta({required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: _firebaseAuth.currentUser!.email!, password: senha);
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  // Método para registrar uma refeição
  Future<String?> registrarRefeicao({
    required String userId,
    required DateTime hora,
    String? descricao,
  }) async {
    try {
      //String horaFormatada =  "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('refeicoes')
          .add({
        'hora': hora,
        'descricao': descricao,
      });
    } on FirebaseException catch (e) {
      return e.code;
    }
    return null;
  }

  // Método para obter todas as refeições de um usuário
  Future<List<Map<String, dynamic>>> obterRefeicoes(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('refeicoes')
          .orderBy('hora')
          .get();

      return querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['refeicaoId'] = doc.id; // Adiciona o documentId
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      print('Erro ao obter refeições: $e');
      return [];
    }
  }

  Future<String?> atualizarRefeicao({
  required String userId,
  required String refeicaoId,
  required DateTime hora,
  required String descricao,
}) async {
  try {
    await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('refeicoes')
      .doc(refeicaoId)
      .update({
        'hora': Timestamp.fromDate(hora),
        'descricao': descricao,
      });
    return null;
  } catch (e) {
    return 'Erro ao atualizar refeição: $e';
  }
}


   // Método para excluir uma refeição
  Future<String?> excluirRefeicao({
    required String userId,
    required String refeicaoId,
  }) async {
    try {
      // Remove o documento da refeição com o ID fornecido
      await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('refeicoes')
          .doc(refeicaoId)
          .delete();
    } on FirebaseException catch (e) {
      print('Erro ao excluir refeição: $e');
      return e.code;
    }
    return null;
  }
}

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfilePicture(File file, String userId) async {
    try {
      // Cria um caminho para a imagem no Firebase Storage
      final fileName = path.basename(file.path);
      final ref = _storage.ref().child('profile_pictures/$userId/$fileName');

      // Faz o upload do arquivo
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Obtém a URL de download da imagem
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_email_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:bety_sprint1/screens/adicionar_refeicao_screen.dart';
//import 'packag  e:intl/intl.dart';

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
   // Adicionar registro de glicemia
  Future<String?> adicionarRegistroGlicemia({
    required String userId,
    required double concentracao,
    required DateTime dataHora,
    required String tipoMedicao,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('glucoseRecords')
          .add({
        'concentracao': concentracao,
        'dataHora': Timestamp.fromDate(dataHora),
        'tipoMedicao': tipoMedicao,
      });
      return null;
    } catch (e) {
      return 'Erro ao adicionar registro de glicemia: $e';
    }
  }

  // Atualizar registro de glicemia
  Future<String?> atualizarRegistroGlicemia({
    required String userId,
    required String recordId,
    required double concentracao,
    required DateTime dataHora,
    required String tipoMedicao,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('glucoseRecords')
          .doc(recordId)
          .update({
        'concentracao': concentracao,
        'dataHora': Timestamp.fromDate(dataHora),
        'tipoMedicao': tipoMedicao,
      });
      return null;
    } catch (e) {
      return 'Erro ao atualizar registro de glicemia: $e';
    }
  }

  // Excluir registro de glicemia
  Future<String?> excluirRegistroGlicemia({
    required String userId,
    required String recordId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('glucoseRecords')
          .doc(recordId)
          .delete();
      return null;
    } catch (e) {
      return 'Erro ao excluir registro de glicemia: $e';
    }
  }
  Stream<QuerySnapshot> obterRegistrosGlicemia(String userId) {
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('glucoseRecords')
        .orderBy('dataHora', descending: true)
        .snapshots();
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

class RefeicaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> adicionarRefeicao({
    required String userId,
    required Refeicao refeicao,
  }) async {
    await _firestore.collection('usuarios').doc(userId).collection('refeicoes').add(refeicao.toFirestore());
  }

  Future<void> atualizarRefeicao({
    required String userId,
    required Refeicao refeicao,
  }) async {
    if (refeicao.id != null) {
      await _firestore.collection('usuarios').doc(userId).collection('refeicoes').doc(refeicao.id).update(refeicao.toFirestore());
    } else {
      throw Exception('Refeição sem ID');
    }
  }

  Future<void> excluirRefeicao({
    required String userId,
    required String refeicaoId,
  }) async {
    await _firestore.collection('usuarios').doc(userId).collection('refeicoes').doc(refeicaoId).delete();
  }

  // Para obter uma lista de refeições
  Future<List<Refeicao>> getRefeicoes(String userId) async {
    QuerySnapshot snapshot = await _firestore.collection('usuarios').doc(userId).collection('refeicoes').get();
    return snapshot.docs.map((doc) => Refeicao.fromFirestore(doc)).toList();
  }
}


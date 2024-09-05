import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final UserService _usuarioService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para registrar um novo usuário
  Future<void> signUp({
    required String email,
    required String password,
    required String nome,
    required String tipoDeDiabetes,
    required DateTime dataDeNascimento,
  }) async {
    try {
      // Criação do usuário com Firebase Authentication
      auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obter o UID do usuário recém-criado
      String uid = userCredential.user!.uid;
      DocumentReference userRef = _firestore.collection('users').doc(uid);

      // Criar o objeto User com os dados adicionais
      User newUser = User(
        uid: userRef,
        email: email,
        nome: nome,
        tipoDeDiabetes: tipoDeDiabetes,
        dataDeNascimento: dataDeNascimento,
      );

      // Salvar os dados do usuário no Firestore
      await _usuarioService.saveUser(newUser);
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      // Tratar erros, como exibir uma mensagem de erro ao usuário
    }
  }

  // Função para fazer login de um usuário
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Autenticar o usuário com email e senha
      auth.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obter o UID do usuário autenticado
      String uid = userCredential.user!.uid;
      String currentEmail = userCredential.user!.email!;
      DocumentReference userRef = _firestore.collection('users').doc(uid);

      // Buscar os dados do usuário do Firestore
      User? user = await _usuarioService.getUser(userRef);

      // Armazenar o usuário na SessionManager
      if (user != null) {
        SessionManager().currentUser = user;
        if (user.email != currentEmail) {
          await userRef.update({'email': currentEmail});
          await SessionManager().updateUserInSession();
        }
      }

      // Retornar o objeto User
      return user;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }

  // Atualizar o e-mail do usuário
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user != null) {
        // Enviar um e-mail de verificação para o novo e-mail
        await user.verifyBeforeUpdateEmail(newEmail);

        // Notificar o usuário para verificar o e-mail e atualizar o e-mail
        print(
            'E-mail de verificação enviado para $newEmail. Verifique sua caixa de entrada.');
      } else {
        throw Exception('Usuário não está autenticado.');
      }
    } catch (e) {
      print('Erro ao atualizar e-mail: $e');
      // Tratar erros, como exibir uma mensagem de erro ao usuário
    }
  }

  // Deslogar o usuário
  Future<void> signOut() async {
    await auth.FirebaseAuth.instance.signOut();
    SessionManager().clearSession();
  }

  // Função de redefinir senha
  Future<String?> redefinicaoSenha({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'invalid-email':
          return 'Endereço de e-mail inválido';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde';
        default:
          return 'Erro desconhecido: ${e.message}';
      }
    } catch (e) {
      // Catch any other exceptions
      return 'Erro inesperado: $e';
    }
    return null;
  }
}

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  User? _currentUser;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  User? get currentUser => _currentUser;

  set currentUser(User? user) {
    _currentUser = user;
  }

  // Método para verificar e carregar o usuário autenticado
  Future<void> checkAndLoadUser() async {
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(authUser.uid);
      User? fetchedUser = await UserService().getUser(userRef);
      if (fetchedUser != null) {
        _currentUser = fetchedUser;
      }
    }
  }

  // Atualizar o usuário na sessão
  Future<void> updateUserInSession() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      User? user = await UserService().getUser(userRef);
      if (user != null) {
        _currentUser = user;
      }
    }
  }

  // Limpar a sessão do usuário
  void clearSession() {
    _currentUser = null;
  }
}

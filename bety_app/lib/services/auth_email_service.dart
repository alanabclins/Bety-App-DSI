import 'package:firebase_auth/firebase_auth.dart';

class AuthEmailService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyBeforeUpdateEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
    } else {
      throw Exception("Usuário não autenticado.");
    }
  }
}

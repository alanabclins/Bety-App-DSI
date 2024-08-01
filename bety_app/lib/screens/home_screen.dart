import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Home',
        subtitle: '',
        showLogoutButton: false,
        onBackButtonPressed: () {
          // Implementar ação para voltar
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem vindo ${user.displayName}!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Bem-vindo, ${user.email}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

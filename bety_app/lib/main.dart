//import 'package:bety_sprint1/screens/login_screen.dart';
//import 'package:bety_sprint1/screens/cadastro_screen.dart';
import 'package:bety_sprint1/screens/login_screen.dart';
import 'package:bety_sprint1/screens/notificacao_screen.dart';
//import 'package:bety_sprint1/screens/registro_glicemia.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: LoginScreen(),
    );
  }
}

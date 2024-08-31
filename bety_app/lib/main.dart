import 'package:bety_sprint1/screens/adicionar_refeicao_screen.dart';
import 'package:bety_sprint1/screens/altera_dados.dart';
import 'package:bety_sprint1/screens/recuperar_senha.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/notificacao_screen.dart';
import 'screens/registro_glicemia.dart';
import 'screens/mapa-screen.dart';
//import 'screens/tela_Perfil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/models/user.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFFBFAF3)),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/cadastro': (context) => CadastroScreen(),
        '/home': (context) => DadosCadastraisScreen(),
        '/notificacao': (context) => NotificacaoScreen(),
        '/registroGlicemia': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return MedicaoGlicoseScreen(
              user: args['user'], userData: args['userData']);
        },
        '/recuperar_senha': (context) => RecuperarSenhaScreen(),
        //'/perfil': (context) {
         // final args = ModalRoute.of(context)!.settings.arguments
           //   as Map<String, dynamic>;
          //return ProfileScreen(user: args['user'], userData: args['userData']);
        //},
      },
    );
  }
}


class RoteadorTelas extends StatelessWidget {
  const RoteadorTelas({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém o usuário atual do SessionManager
    final User? currentUser = SessionManager().currentUser;

    if (currentUser == null) {
      // Se o usuário não está autenticado, redireciona para a tela de login
      return LoginScreen();
    } else {
      // Se o usuário está autenticado, redireciona para a tela principal
      return MainScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = SessionManager().currentUser;

    return Scaffold(
      body: user != null
          ? [
              //HomeScreen(),
              NotificacaoScreen(),
              //MedicaoGlicoseScreen(),
              //ProfileScreen(),
              //MapaScreen(),
            ][_selectedIndex]
          : Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0BAB7C),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Color(0xFF0BAB7C),
            selectedItemColor: Color(0xFFFAFAFA),
            unselectedItemColor: Colors.white.withOpacity(0.7),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Notificações',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services),
                label: 'Registro',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Mapa',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
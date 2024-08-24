import 'package:bety_sprint1/screens/recuperar_senha.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/notificacao_screen.dart';
import 'screens/registro_glicemia.dart';
import 'screens/mapa-screen.dart';
import 'screens/tela_Perfil.dart'; // Certifique-se de importar a tela correta

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>(
          create: (context) => NotificationService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
<<<<<<< HEAD
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
<<<<<<< HEAD
      home: NotificacaoScreen(),
=======
=======
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFFBFAF3)),
>>>>>>> main
      home: RoteadorTelas(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/cadastro': (context) => CadastroScreen(),
        '/home': (context) => MainScreen(),
        '/notificacao': (context) => NotificacaoScreen(),
        '/registroGlicemia': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return MedicaoGlicoseScreen(
              user: args['user'], userData: args['userData']);
        },
        '/recuperar_senha': (context) => RecuperarSenhaScreen(),
        '/perfil': (context) {
          // Obtenha os parâmetros passados para a tela ProfileScreen
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ProfileScreen(user: args['user'], userData: args['userData']);
        },
      },
    );
  }
}

class RoteadorTelas extends StatelessWidget {
  const RoteadorTelas({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            return MainScreen();
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Função para obter os dados do usuário do Firebase
  Future<Map<String, dynamic>> getUserData(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erro ao carregar dados'),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text('Nenhum dado encontrado'),
            ),
          );
        }

        final userData = snapshot.data!;

        final List<Widget> _pages = [
          HomeScreen(user: user),
          NotificacaoScreen(),
          MedicaoGlicoseScreen(user: user, userData: userData),
          ProfileScreen(user: user, userData: userData),
          // ProfileScreen(user: user, userData: userData),
          MapaScreen(user: user),
        ];

        void _onItemTapped(int index) {
          setState(() {
            _selectedIndex = index;
          });
        }

        return Scaffold(
          body: _pages[_selectedIndex],
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
                onTap: _onItemTapped,
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
      },
>>>>>>> main
    );
  }
}

import 'package:bety_sprint1/screens/mapa-screen.dart';
import 'package:bety_sprint1/screens/tela_Perfil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/notificacao_screen.dart';
import 'screens/registro_glicemia.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      ),
      home: RoteadorTelas(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/cadastro': (context) => CadastroScreen(),
        '/home': (context) => MainScreen(),
        '/notificacao': (context) => NotificacaoScreen(),
        '/registroGlicemia': (context) => MedicaoGlicoseScreen(),
        '/perfil': (context) => ProfileScreen(
            user: FirebaseAuth.instance.currentUser!,
            'yRfMq5CT7XWCKX0I8U938JEO7c73'), // Adicione sua rota extra
      },
    );
  }
}

class RoteadorTelas extends StatelessWidget {
  const RoteadorTelas({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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

  final List<Widget> _pages = [
    HomeScreen(user: FirebaseAuth.instance.currentUser!),
    NotificacaoScreen(),
    MedicaoGlicoseScreen(),
    ProfileScreen(
        user: FirebaseAuth.instance.currentUser!,
        'yRfMq5CT7XWCKX0I8U938JEO7c73'), // Adicione sua tela extra
    MapaScreen(), // Adicione sua tela extra
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
  }
}

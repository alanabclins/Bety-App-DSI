import 'package:bety_sprint1/screens/recuperar_senha.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/notificacao_screen.dart';
import 'screens/registro_glicemia.dart';
import 'screens/mapa-screen.dart';
import 'screens/tela_Perfil.dart';
import 'services/session_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('pt'), const Locale('br')],
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFBFAF3),
      ),
      home: const RoteadorTelas(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/home': (context) => const MainScreen(),
        '/notificacao': (context) => NotificacaoScreen(),
        '/registroGlicemia': (context) => MedicaoGlicoseScreen(),
        '/recuperar_senha': (context) => RecuperarSenhaScreen(),
        '/perfil': (context) => ProfileScreen(),
      },
    );
  }
}

class RoteadorTelas extends StatelessWidget {
  const RoteadorTelas({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionManager().currentUser;

    if (user != null) {
      return const MainScreen();
    } else {
      return LoginScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  dynamic _pageParams;

  final List<Widget Function(dynamic)> _pages = [
    (params) => HomeScreen(),
    (params) => NotificacaoScreen(),
    (params) => MedicaoGlicoseScreen(),
    (params) => ProfileScreen(),
    //(params) => MapaScreen(), // Se quiser incluir o mapa
  ];

  void _updatePage(int index, {dynamic params}) {
    setState(() {
      _selectedIndex = index;
      _pageParams = params;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex](_pageParams),
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
            onTap: (index) => _updatePage(index),
            backgroundColor: const Color(0xFF0BAB7C),
            selectedItemColor: const Color(0xFFFAFAFA),
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
              //BottomNavigationBarItem(
              //  icon: Icon(Icons.map),
              // label: 'Mapa',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationHelper {
  static void navigateToPage(BuildContext context, int index,
      {dynamic params}) {
    final _MainScreenState? bottomNavState =
        context.findAncestorStateOfType<_MainScreenState>();
    if (bottomNavState != null) {
      bottomNavState._updatePage(index, params: params);
    }
  }
}

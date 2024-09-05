import 'package:bety_sprint1/main.dart';
import 'package:bety_sprint1/models/refeicao.dart';
import 'package:bety_sprint1/models/local.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/utils/buildFeatureCard.dart';
import 'package:bety_sprint1/utils/buildNotesSection.dart';
import 'package:bety_sprint1/utils/showBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/models/glicemia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Obter o usuário atual do SessionManager
    final usuario = SessionManager().currentUser;

    // Se o usuário não estiver logado ou o SessionManager não tiver dados do usuário
    if (usuario == null) {
      return Scaffold(
        appBar: CustomAppBar(
          mainTitle: 'Home',
          subtitle: '',
          showLogoutButton: false,
          backgroundColor: Color(0xFF0BAB7C),
        ),
        body: Center(child: Text('Nenhum dado encontrado')),
      );
    }

    String formatTimestamp(Timestamp timestamp) {
      final dateTime = timestamp.toDate();
      final formatter = DateFormat('HH:mm');
      return formatter.format(dateTime);
    }

    // Use um FutureBuilder para lidar com a chamada assíncrona
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: ' ',
        subtitle: 'Pronto para gerenciar sua saúde?',
        showLogoutButton: false,
        backgroundColor: Color(0xFF0BAB7C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Olá, ${usuario.nome}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0BAB7C),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<Refeicao?>(
              stream: RefeicaoService().getNextRefeicao(
                  usuario.uid), // Modifique para retornar um Stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                      'Você pode adicionar uma refeição na tela alterar dados');
                } else {
                  final refeicao = snapshot.data;
                  if (refeicao != null) {
                    return BuildFeatureCard(
                      icon: Icons.restaurant,
                      title: 'Próxima Refeição',
                      subtitle: '${refeicao.descricao} às ${refeicao.hora}',
                      onTap: () => NavigationHelper.navigateToPage(context, 3),
                    );
                  } else {
                    return BuildFeatureCard(
                      icon: Icons.restaurant,
                      title: 'Próxima Refeição',
                      subtitle:
                          'Você pode adicionar uma refeição na tela alterar dados',
                      onTap: () => NavigationHelper.navigateToPage(context, 3),
                    );
                  }
                }
              },
            ),
            StreamBuilder<List<Local>>(
              stream: LocalService().getLocaisPorUsuario(usuario.uid), // Retorna um Stream de uma lista de locais
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar os pontos de apoio');
                } else {
                  final locais = snapshot.data;
                  if (locais != null && locais.isNotEmpty) {
                    return FutureBuilder<Local?>(
                      future: LocalService().obterLocalMaisProximo(), // Obtém o local mais próximo
                      builder: (context, futureSnapshot) {
                        if (futureSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (futureSnapshot.hasError) {
                          return Text('Erro ao encontrar o local mais próximo');
                        } else {
                          final localMaisProximo = futureSnapshot.data;
                          if (localMaisProximo != null) {
                            return BuildFeatureCard(
                              icon: Icons.map,
                              title: 'Mapa de Pontos de Apoio',
                              subtitle: 'Ponto mais próximo: ${localMaisProximo.apelido}',
                              onTap: () => NavigationHelper.navigateToPage(context, 4),
                            );
                          } else {
                            return BuildFeatureCard(
                              icon: Icons.map,
                              title: 'Mapa de Pontos de Apoio',
                              subtitle: 'Você pode adicionar locais na tela alterar dados',
                              onTap: () => NavigationHelper.navigateToPage(context, 4),
                            );
                          }
                        }
                      },
                    );
                  } else {
                    return BuildFeatureCard(
                      icon: Icons.map,
                      title: 'Mapa de Pontos de Apoio',
                      subtitle: 'Você pode adicionar locais na tela alterar dados',
                      onTap: () => NavigationHelper.navigateToPage(context, 4),
                    );
                  }
                }
              },
            ),
            StreamBuilder<Glicemia?>(
              stream: GlicemiaService().getUltimaGlicemia(
                  usuario.uid), // Use o novo método de stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                      'Você pode adicionar uma medição na tela alterar dados');
                } else {
                  final glicemia = snapshot.data;
                  if (glicemia != null) {
                    return BuildFeatureCard(
                      icon: Icons.favorite,
                      title: 'Última Glicemia',
                      subtitle:
                          '${glicemia.concentracao} mg/dL às ${formatTimestamp(glicemia.dataHora)}',
                      onTap: () => NavigationHelper.navigateToPage(context, 2),
                    );
                  } else {
                    return BuildFeatureCard(
                      icon: Icons.favorite,
                      title: 'Última Glicemia',
                      subtitle: 'Nenhuma medição registrada',
                      onTap: () => NavigationHelper.navigateToPage(context, 2),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            NotesSection(),
            const SizedBox(height: 20),
            _buildAddNoteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: title,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF0BAB7C),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0BAB7C),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BAB7C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddNoteButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showNoteBottomSheet(context);
      },
      icon: Icon(Icons.add),
      label: Text('Adicionar Nota'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0BAB7C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
        foregroundColor: Color(0xFFFBFAF3),
        textStyle: TextStyle(
            color: Color(0xFFFBFAF3),
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

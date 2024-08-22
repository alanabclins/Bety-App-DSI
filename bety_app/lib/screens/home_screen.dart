import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _userData;

  @override
  void initState() {
    super.initState();
    _userData = _getUserData();
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .get();
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Home',
        subtitle: '',
        showLogoutButton: false,
        onBackButtonPressed: () {
          // Implementar ação para voltar, se necessário
        },
        backgroundColor: Color(0xFF0BAB7C),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Nenhum dado encontrado'));
          }

          final userData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Olá, ${userData['nome']}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0BAB7C),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFeatureCard(
                  context,
                  icon: Icons.notifications,
                  title: 'Notificações',
                  subtitle: 'Próxima: Refeição às 12:00 PM',
                  onTap: () => Navigator.pushNamed(context, '/notificacoes'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.map,
                  title: 'Mapa de Pontos de Apoio',
                  subtitle: '3 pontos próximos',
                  onTap: () => Navigator.pushNamed(context, '/mapa'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.health_and_safety,
                  title: 'Registro de Glicemia',
                  subtitle: 'Última: 110 mg/dL',
                  onTap: () => Navigator.pushNamed(context, '/glicemia'),
                ),
                const SizedBox(height: 20),
                _buildNotesSection(context),
                const SizedBox(height: 20),
                _buildAddNoteButton(context),
              ],
            ),
          );
        },
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

  Widget _buildNotesSection(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user.uid)
          .collection('notas')
          .orderBy('timestamp', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Sem notas adicionadas.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final notes = snapshot.data!.docs;

        return SizedBox(
          height: 200, // Altura do carrossel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final doc = notes[index];
              final note = doc.data() as Map<String, dynamic>;
              final date = (note['timestamp'] as Timestamp).toDate();

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                color: Color(0xFF0BAB7C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  width: 370, // Largura de cada card no carrossel
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.note,
                              color: Color(0xFF0BAB7C),
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nota rápida',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  note['text'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _addOrEditNote(
                              noteId: doc.id,
                              currentText: note['text'],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNote(doc.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddNoteButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _addOrEditNote(),
      icon: Icon(Icons.add),
      label: Text('Adicionar Nota'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF0BAB7C), // Cor do texto e ícone
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  Future<void> _addOrEditNote({String? noteId, String? currentText}) async {
    final TextEditingController controller = TextEditingController(
      text: currentText ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(noteId == null ? 'Adicionar Nota' : 'Editar Nota'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Escreva sua nota aqui...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  _saveNote(noteId, text);
                  Navigator.of(context).pop();
                }
              },
              child: Text(noteId == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote(String? noteId, String text) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('notas');

    if (noteId == null) {
      // Adicionar nova nota
      await collectionRef.add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Atualizar nota existente
      await collectionRef.doc(noteId).update({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() {});
  }

  Future<void> _deleteNote(String noteId) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('notas')
        .doc(noteId)
        .delete();

    setState(() {});
  }
}

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
    // Obtém os dados do usuário
    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .get();

    // Obtém o último registro de glicose na subcoleção glucoseRecords
    final glucoseRecordDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('glucoseRecords')
        .orderBy('date',
            descending: true) // Ordena por data para pegar o mais recente
        .limit(1)
        .get();

    // Extrai os dados principais do usuário
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    // Adiciona o valor de glucose ao mapa de dados do usuário
    if (glucoseRecordDoc.docs.isNotEmpty) {
      userData['glucose'] = glucoseRecordDoc.docs.first.data()['glucose'];
    } else {
      userData['glucose'] = null; // Se não houver registros, define como null
    }

    return userData;
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
          final lastGlucose = userData['glucose'] != null
              ? 'Última: ${userData['glucose']} mg/dL'
              : 'Sem registro de glicose';

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
                  subtitle: lastGlucose, // Aqui usamos o dado de glicose
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
                            icon: Icon(Icons.edit,
                                color: const Color(0xFFFBFAF3)),
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
      icon: Icon(Icons.add, color: Color(0xFFFBFAF3)),
      label: Text(
        'Adicionar nota',
        style: TextStyle(color: Color(0xFFFBFAF3)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0BAB7C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  void _addOrEditNote({String? noteId, String? currentText}) {
    final TextEditingController _noteController =
        TextEditingController(text: currentText ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(noteId != null ? 'Editar Nota' : 'Adicionar Nota'),
          content: TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Digite sua nota aqui',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (noteId != null) {
                  _updateNote(noteId, _noteController.text);
                } else {
                  _saveNote(_noteController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote(String text) async {
    if (text.isNotEmpty) {
      final newNote = {
        'text': text,
        'timestamp': Timestamp.now(),
      };
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user.uid)
          .collection('notas')
          .add(newNote);
      setState(() {});
    }
  }

  Future<void> _updateNote(String noteId, String newText) async {
    if (newText.isNotEmpty) {
      final updatedNote = {
        'text': newText,
        'timestamp': Timestamp.now(),
      };
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user.uid)
          .collection('notas')
          .doc(noteId)
          .update(updatedNote);
      setState(() {});
    }
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

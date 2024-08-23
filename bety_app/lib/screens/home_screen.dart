import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _userData;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _userData = _getUserData();
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .get();

    final glucoseRecordDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('glucoseRecords')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    if (glucoseRecordDoc.docs.isNotEmpty) {
      userData['glucose'] = glucoseRecordDoc.docs.first.data()['glucose'];
    } else {
      userData['glucose'] = null;
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
        onBackButtonPressed: () {},
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
                  subtitle: lastGlucose,
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
          height: 225, // Altura do carrossel
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
                                if (note['imageUrl'] != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showImageDialog(note['imageUrl']!);
                                      },
                                      child: Text('Visualizar Imagem'),
                                    ),
                                  ),
                                Text(
                                  'Data: ${date.day}/${date.month}/${date.year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
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
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              _addOrEditNote(
                                noteId: doc.id,
                                currentText: note['text'],
                                currentImageUrl: note['imageUrl'],
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: const Color.fromARGB(255, 255, 12, 12)),
                            onPressed: () async {
                              await _deleteNote(doc.id);
                              setState(() {});
                            },
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

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddNoteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _addOrEditNote();
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFFC7F4C2),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Adicionar Nota',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0BAB7C),
            ),
          ),
        ),
      ),
    );
  }

  void _addOrEditNote({
    String? noteId,
    String? currentText,
    String?
        currentImageUrl, // Agora estamos recebendo a URL da imagem existente
  }) {
    TextEditingController textController =
        TextEditingController(text: currentText);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Escreva sua nota...',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedImage != null) {
                    setState(() {
                      _selectedImage = File(pickedImage.path);
                    });
                  }
                },
                child: Text('Selecionar Imagem'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (noteId == null) {
                    await _saveNote(
                      textController.text,
                      _selectedImage,
                    );
                  } else {
                    await _updateNote(
                      noteId,
                      textController.text,
                      currentImageUrl, // Passando a URL da imagem existente
                    );
                  }
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text(noteId == null ? 'Salvar Nota' : 'Atualizar Nota'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveNote(String text, File? imageFile) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile);
    }

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('notas')
        .add({
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> _updateNote(
    String noteId,
    String text,
    String? imageUrl,
  ) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('notas')
        .doc(noteId)
        .update({
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> _deleteNote(String noteId) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.user.uid)
        .collection('notas')
        .doc(noteId)
        .delete();
  }

  Future<String> _uploadImage(File imageFile) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('notesImages')
        .child(widget.user.uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _deleteImage(String imageUrl) async {
    final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    await storageRef.delete();
  }
}

import 'package:bety_sprint1/models/refeicao.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
          onBackButtonPressed: () {},
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
        mainTitle: 'Home',
        subtitle: '',
        showLogoutButton: false,
        onBackButtonPressed: () {},
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
              stream: RefeicaoService().getNextRefeicao(usuario.uid), // Modifique para retornar um Stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Você pode adicionar uma refeição na tela alterar dados');
                } else {
                  final refeicao = snapshot.data;
                  if (refeicao != null) {
                    return _buildFeatureCard(
                      context,
                      icon: Icons.restaurant,
                      title: 'Próxima Refeição',
                      subtitle: '${refeicao.descricao} às ${refeicao.hora}',
                      onTap: () => Navigator.pushNamed(context, '/perfil'),
                    );
                  } else {
                    return _buildFeatureCard(
                      context,
                      icon: Icons.restaurant,
                      title: 'Próxima Refeição',
                      subtitle: 'Você pode adicionar uma refeição na tela alterar dados',
                      onTap: () => Navigator.pushNamed(context, '/perfil'),
                    );
                  }
                }
              },
            ),
            _buildFeatureCard(
              context,
              icon: Icons.map,
              title: 'Mapa de Pontos de Apoio',
              subtitle: '3 pontos próximos',
              onTap: () => Navigator.pushNamed(context, '/mapa'),
            ),
            StreamBuilder<Glicemia?>(
              stream: GlicemiaService().getUltimaGlicemia(usuario.uid), // Use o novo método de stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Você pode adicionar uma medição na tela alterar dados');
                } else {
                  final glicemia = snapshot.data;
                  if (glicemia != null) {
                    return _buildFeatureCard(
                      context,
                      icon: Icons.favorite,
                      title: 'Última Glicemia',
                      subtitle: '${glicemia.concentracao} mg/dL às ${formatTimestamp(glicemia.dataHora)}',
                      onTap: () => Navigator.pushNamed(context, '/registroGlicemia'),
                    );
                  } else {
                    return _buildFeatureCard(
                      context,
                      icon: Icons.favorite,
                      title: 'Última Glicemia',
                      subtitle: 'Nenhuma medição registrada',
                      onTap: () => Navigator.pushNamed(context, '/registroGlicemia'),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            _buildNotesSection(context),
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

Widget _buildNotesSection(BuildContext context) {
  final usuario = SessionManager().currentUser;
  // Verifica se o usuário está disponível
  if (usuario == null) {
    return Center(
      child: Text(
        'Usuário não encontrado.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  return StreamBuilder<List<Nota>>(
    stream: NotaService().getNotasPorUsuario(usuario.uid),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(
          child: Text(
            'Sem notas adicionadas.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      final notes = snapshot.data!;

      return SizedBox(
        height: 225, // Altura do carrossel
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final date = note.timestamp.toDate();
            final imageUrl = note.imagemUrl;

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
                                note.titulo,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: Text(
                        note.descricao,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            _showImageDialog(context, imageUrl);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Text(
                            'Ver Imagem',
                            style: TextStyle(color: Color(0xFF0BAB7C)),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white70),
                            onPressed: () {
                              // Passa o DocumentReference ao método de edição, se necessário
                              _showNoteBottomSheet(context, nota: note);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: const Color.fromARGB(179, 249, 34, 34)),
                            onPressed: () async {
                              await NotaService().deletarNota(note.id!);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
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
        _showNoteBottomSheet(context);
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

  void _showNoteBottomSheet(BuildContext context, {Nota? nota}) {
    final titleController = TextEditingController(text: nota?.titulo ?? '');
    final descriptionController = TextEditingController(text: nota?.descricao ?? '');
    String? imageUrl = nota?.imagemUrl;
    File? _selectedImage;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nota == null ? 'Adicionar Nova Nota' : 'Editar Nota',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0BAB7C),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );

                    if (pickedFile != null) {
                      setState(() {
                        _selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: Text('Selecionar Imagem'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BAB7C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    foregroundColor: Color(0xFFFBFAF3),
                    textStyle: TextStyle(
                        color: Color(0xFFFBFAF3),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text;
                    final description = descriptionController.text;

                    if (title.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Preencha todos os campos')),
                      );
                      return;
                    }

                    if (nota != null) {
                      // Editar nota existente
                      String? updatedImageUrl = imageUrl;
                      if (_selectedImage != null) {
                        updatedImageUrl = await NotaService().atualizarImagemNota(
                          nota.id!,
                          _selectedImage!.path,
                        );
                      }

                      final updatedNote = Nota(
                        userRef: SessionManager().currentUser!.uid,
                        id: nota.id,
                        titulo: title,
                        descricao: description,
                        timestamp: nota.timestamp,
                        imagemUrl: updatedImageUrl ?? imageUrl,
                      );

                      await NotaService().atualizarNota(updatedNote);
                    } else {
                      // Adicionar nova nota
                      String? imageUrl;
                      Nota tempNota;

                      if (_selectedImage != null) {
                        tempNota = Nota(
                          userRef: SessionManager().currentUser!.uid,
                          titulo: title,
                          descricao: description,
                          timestamp: Timestamp.now(),
                        );

                        final tempNotaAdded = await NotaService().adicionarNota(tempNota);

                        imageUrl = await NotaService().atualizarImagemNota(
                          tempNotaAdded.id!,
                          _selectedImage!.path,
                        );

                        tempNota = Nota(
                          userRef: SessionManager().currentUser!.uid,
                          id: tempNotaAdded.id,
                          titulo: title,
                          descricao: description,
                          timestamp: Timestamp.now(),
                          imagemUrl: imageUrl,
                        );
                        await NotaService().atualizarNota(tempNota);
                      } else {
                        final newNote = Nota(
                          userRef: SessionManager().currentUser!.uid,
                          id: null,
                          titulo: title,
                          descricao: description,
                          timestamp: Timestamp.now(),
                          imagemUrl: null,
                        );

                        await NotaService().adicionarNota(newNote);
                      }
                    }

                    Navigator.pop(context);
                  },
                  child: Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BAB7C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    foregroundColor: Color(0xFFFBFAF3),
                    textStyle: TextStyle(
                      color: Color(0xFFFBFAF3),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
import 'package:bety_sprint1/utils/showBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:bety_sprint1/models/nota.dart';
import 'package:bety_sprint1/services/session_service.dart';

class NotesSection extends StatefulWidget {
  @override
  _NotesSectionState createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  @override
  Widget build(BuildContext context) {
    final usuario = SessionManager().currentUser;

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
          height: 225,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final date = note.timestamp.toDate();
              final imageUrl = note.imagemUrl;

              // Formatação da data para o padrão dd/MM/yyyy
              final formattedDate =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                color: Color(0xFF0BAB7C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  width: 370,
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
                                  formattedDate,
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
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
                                showNoteBottomSheet(context, nota: note);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color:
                                      const Color.fromARGB(179, 249, 34, 34)),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, note);
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Nota note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja deletar esta nota?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await NotaService().deletarNota(note.id!);
                Navigator.of(context).pop(); // Fechar o diálogo
                setState(() {}); // Atualizar a lista de notas
              },
              child: Text('Deletar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bety_sprint1/models/nota.dart';
import 'package:bety_sprint1/services/session_service.dart';

void showNoteBottomSheet(BuildContext context, {Nota? nota}) {
  final titleController = TextEditingController(text: nota?.titulo ?? '');
  final descriptionController =
      TextEditingController(text: nota?.descricao ?? '');
  String? imageUrl = nota?.imagemUrl;
  File? _selectedImage;
  bool _isUploadingImage = false;
  bool _isSavingNote = false;
  String _buttonText = '+ Adicionar imagem'; // Variável para o texto do botão

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
                    onPressed: _isUploadingImage
                        ? null
                        : () async {
                            setState(() {
                              _isUploadingImage = true;
                            });

                            final pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );

                            if (pickedFile != null) {
                              _selectedImage = File(pickedFile.path);
                              setState(() {
                                _buttonText =
                                    'Imagem já adicionada'; // Altera o texto do botão
                              });
                            }

                            setState(() {
                              _isUploadingImage = false;
                            });
                          },
                    child: _isUploadingImage
                        ? CircularProgressIndicator()
                        : Text(_buttonText), // Usa a variável de texto do botão
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0BAB7C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      foregroundColor: Color(0xFFFBFAF3),
                      textStyle: TextStyle(
                          color: Color(0xFFFBFAF3),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSavingNote
                        ? null
                        : () async {
                            setState(() {
                              _isSavingNote = true;
                            });

                            final title = titleController.text;
                            final description = descriptionController.text;

                            if (title.isEmpty || description.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Preencha todos os campos'),
                                ),
                              );
                              setState(() {
                                _isSavingNote = false;
                              });
                              return;
                            }

                            if (nota != null) {
                              // Editar nota existente
                              String? updatedImageUrl = imageUrl;
                              if (_selectedImage != null) {
                                updatedImageUrl =
                                    await NotaService().atualizarImagemNota(
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

                                final tempNotaAdded =
                                    await NotaService().adicionarNota(tempNota);

                                imageUrl =
                                    await NotaService().atualizarImagemNota(
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

                            setState(() {
                              _isSavingNote = false;
                            });

                            Navigator.pop(context);
                          },
                    child: _isSavingNote
                        ? CircularProgressIndicator()
                        : Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0BAB7C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
    },
  );
}

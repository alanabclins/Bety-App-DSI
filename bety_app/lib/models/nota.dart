import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Nota {
  DocumentReference? id; // Referência ao documento da nota (opcional)
  DocumentReference userRef; // Referência ao documento do usuário
  String titulo;
  String descricao;
  Timestamp timestamp;
  String? imagemUrl; // URL da imagem opcional

  Nota({
    this.id, // O id pode ser nulo até ser atribuído
    required this.userRef,
    required this.titulo,
    required this.descricao,
    required this.timestamp,
    this.imagemUrl,
  });

  // Converte um objeto Nota para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'userRef': userRef, // Armazena a referência do usuário
      'titulo': titulo,
      'descricao': descricao,
      'timestamp': timestamp,
      'imagemUrl': imagemUrl,
    };
  }

  // Converte um mapa JSON para um objeto Nota
  factory Nota.fromJson(Map<String, dynamic> json, DocumentReference? id) {
    return Nota(
      id: id,
      userRef: json['userRef'] as DocumentReference,
      titulo: json['titulo'],
      descricao: json['descricao'],
      timestamp: json['timestamp'],
      imagemUrl: json['imagemUrl'],
    );
  }

  // Converte um documento Firestore para um objeto Nota
  factory Nota.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Nota.fromJson(data, doc.reference);
  }
}


class NotaService {
  final CollectionReference _notasCollection = FirebaseFirestore.instance.collection('notas');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Adicionar uma nova nota
  Future<Nota> adicionarNota(Nota nota) async {
    final docRef = await _notasCollection.add(nota.toJson());
    final notaComId = Nota(
      id: docRef,
      userRef: nota.userRef,
      titulo: nota.titulo,
      descricao: nota.descricao,
      timestamp: nota.timestamp,
      imagemUrl: nota.imagemUrl,
    );
    return notaComId;
  }

  // Obter todas as notas de um usuário específico
  Stream<List<Nota>> getNotasPorUsuario(DocumentReference userRef) {
    return _notasCollection
        .where('userRef', isEqualTo: userRef) // Usa a referência diretamente
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Nota.fromFirestore(doc)).toList());
  }

  // Atualizar uma nota existente
  Future<void> atualizarNota(Nota nota) {
    if (nota.id == null) {
      throw ArgumentError('A nota deve ter um id definido para atualização.');
    }
    return nota.id!.update(nota.toJson());
  }

  // Deletar uma nota
  Future<void> deletarNota(DocumentReference? notaRef) {
    if (notaRef == null) {
      throw ArgumentError('A referência do documento não pode ser nula.');
    }
    return notaRef.delete();
  }

  // Atualizar a imagem da nota
  Future<String?> atualizarImagemNota(DocumentReference notaRef, String filePath) async {
    try {
      Reference ref = _storage.ref().child('notasImagens/${notaRef.id}.jpg');
      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await notaRef.update({
        'imagemUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print('Erro ao atualizar imagem da nota: $e');
      return null;
    }
  }
}

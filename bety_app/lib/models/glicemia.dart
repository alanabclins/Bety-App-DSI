import 'package:cloud_firestore/cloud_firestore.dart';

// Classe Glicemia
class Glicemia {
  DocumentReference? id; // Referência ao documento da glicemia (opcional)
  DocumentReference userRef; // Referência ao documento do usuário
  double concentracao;
  Timestamp dataHora;
  String tipoMedicao;

  Glicemia({
    this.id, // O id pode ser nulo até ser atribuído
    required this.userRef,
    required this.concentracao,
    required this.dataHora,
    required this.tipoMedicao,
  });

  // Converte um objeto Glicemia para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'userRef': userRef, // Armazena a referência diretamente
      'concentracao': concentracao,
      'dataHora': dataHora,
      'tipoMedicao': tipoMedicao,
    };
  }

  // Converte um mapa JSON para um objeto Glicemia
  factory Glicemia.fromJson(Map<String, dynamic> json, DocumentReference? id) {
    return Glicemia(
      id: id,
      userRef: json['userRef'] as DocumentReference,
      concentracao: json['concentracao'],
      dataHora: json['dataHora'],
      tipoMedicao: json['tipoMedicao'],
    );
  }

  // Converte um documento Firestore para um objeto Glicemia
  factory Glicemia.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Glicemia.fromJson(data, doc.reference);
  }
}

// Classe GlicemiaService para gerenciar as glicemias no Firestore
class GlicemiaService {
  final CollectionReference _glicemiasCollection = FirebaseFirestore.instance.collection('glicemias');

  // recuperar o DocumentReference de uma glicemia para edição
  DocumentReference getGlicemiaDocumentReference(String recordId) {
    return _glicemiasCollection.doc(recordId);
  }

  // Adicionar uma nova glicemia
  Future<Glicemia> adicionarGlicemia(Glicemia glicemia) async {
    // Adiciona o documento e obtém a referência do documento criado
    final docRef = await _glicemiasCollection.add(glicemia.toJson());
    // Atualiza o objeto Glicemia com o ID do documento
    final glicemiaComId = Glicemia(
      id: docRef,
      userRef: glicemia.userRef,
      concentracao: glicemia.concentracao,
      dataHora: glicemia.dataHora,
      tipoMedicao: glicemia.tipoMedicao,
    );
    // Retorna o objeto Glicemia atualizado com o ID
    return glicemiaComId;
  }

  // Obter todas as glicemias de um usuário específico
  Stream<List<Glicemia>> getGlicemiasPorUsuario(DocumentReference userRef) {
    return _glicemiasCollection
        .where('userRef', isEqualTo: userRef) // Usa a referência diretamente
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Glicemia.fromFirestore(doc)).toList());
  }

  // Atualizar uma glicemia existente
  Future<void> atualizarGlicemia(Glicemia glicemia) async {
    if (glicemia.id == null) {
      throw ArgumentError('A glicemia deve ter um id definido para atualização.');
    }
    try {
      await glicemia.id!.update(glicemia.toJson());
    } catch (e) {
      print('Erro ao atualizar glicemia: $e');
      rethrow;
    }
  }

  // Deletar uma glicemia
  Future<void> deletarGlicemia(DocumentReference? glicemiaRef) {
    if (glicemiaRef == null) {
      throw ArgumentError('A referência do documento não pode ser nula.');
    }
    return glicemiaRef.delete();
  }

  //função para obter a última glicemia registrada
  Stream<Glicemia?> getUltimaGlicemia(DocumentReference userRef) {
    return _glicemiasCollection
        .where('userRef', isEqualTo: userRef)
        .orderBy('dataHora', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null; // Nenhuma glicemia registrada
          }
          final doc = snapshot.docs.first;
          return Glicemia.fromFirestore(doc);
        })
        .handleError((error) {
          print('Erro no Stream: $error');
          return null; // Retorna null em caso de erro
        });
  }
}
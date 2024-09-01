import 'package:cloud_firestore/cloud_firestore.dart';

class Refeicao {
  DocumentReference? id; // Referência ao documento da refeição (opcional)
  DocumentReference userRef; // Referência ao documento do usuário
  String descricao;
  String hora; // Alterado para String

  Refeicao({
    this.id, // O id pode ser nulo até ser atribuído
    required this.userRef,
    required this.descricao,
    required this.hora, // Alterado para String
  });

  // Converte um objeto Refeicao para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'userRef': userRef, // Armazena a referência diretamente
      'descricao': descricao,
      'hora': hora, // Alterado para String
    };
  }

  // Converte um mapa JSON para um objeto Refeicao
  factory Refeicao.fromJson(Map<String, dynamic> json, DocumentReference? id) {
    return Refeicao(
      id: id,
      userRef: json['userRef'] as DocumentReference,
      descricao: json['descricao'],
      hora: json['hora'] as String, // Alterado para String
    );
  }

  // Converte um documento Firestore para um objeto Refeicao
  factory Refeicao.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Refeicao.fromJson(data, doc.reference);
  }
}

class RefeicaoService {
  final CollectionReference _refeicoesCollection = FirebaseFirestore.instance.collection('refeicoes');

  // Adicionar uma nova refeição
  Future<Refeicao> adicionarRefeicao(Refeicao refeicao) async {
    // Adiciona o documento e obtém a referência do documento criado
    final docRef = await _refeicoesCollection.add(refeicao.toJson());
    // Atualiza o objeto Refeicao com o ID do documento
    final refeicaoComId = Refeicao(
      id: docRef,
      userRef: refeicao.userRef,
      descricao: refeicao.descricao,
      hora: refeicao.hora,
    );
    // Retorna o objeto Refeicao atualizado com o ID
    return refeicaoComId;
  }

  // Obter todas as refeições de um usuário específico
  Stream<List<Refeicao>> getRefeicoesPorUsuario(DocumentReference userRef) {
    return _refeicoesCollection
        .where('userRef', isEqualTo: userRef) // Usa a referência diretamente
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Refeicao.fromFirestore(doc)).toList());
  }

  // Atualizar uma refeição existente
  Future<void> atualizarRefeicao(Refeicao refeicao) {
    if (refeicao.id == null) {
      throw ArgumentError('A refeição deve ter um id definido para atualização.');
    }
    return refeicao.id!.update(refeicao.toJson());
  }

  // Deletar uma refeição
  Future<void> deletarRefeicao(DocumentReference? refeicaoRef) {
    if (refeicaoRef == null) {
      throw ArgumentError('A referência do documento não pode ser nula.');
    }
    return refeicaoRef.delete();
  }

  // Obter a próxima refeição de um usuário
  Stream<Refeicao?> getNextRefeicao(DocumentReference userRef) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'; // Formata a hora atual como "HH:mm"

    return _refeicoesCollection
        .where('userRef', isEqualTo: userRef)
        .where('hora', isGreaterThanOrEqualTo: currentTime) // Usa o tempo atual completo
        .orderBy('hora')
        .limit(1)
        .snapshots()
        .map((querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            return null; // Nenhuma refeição futura encontrada
          }
          final doc = querySnapshot.docs.first;
          return Refeicao.fromFirestore(doc);
        })
        .handleError((error) {
          print('Erro no Stream: $error');
          return null; // Retorna null em caso de erro
        });
  }
}
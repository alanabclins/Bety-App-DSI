import 'package:cloud_firestore/cloud_firestore.dart';

class Local {
  DocumentReference? id; // Referência ao documento do local (opcional)
  DocumentReference userRef; // Referência ao documento do usuário
  double longitude;
  double latitude;
  String nome;

  Local({
    this.id, // O id pode ser nulo até ser atribuído
    required this.userRef,
    required this.longitude,
    required this.latitude,
    required this.nome,
  });

  // Converte um objeto Local para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'userRef': userRef, // Armazena a referência diretamente
      'longitude': longitude,
      'latitude': latitude,
      'nome': nome,
    };
  }

  // Converte um mapa JSON para um objeto Local
  factory Local.fromJson(Map<String, dynamic> json, DocumentReference? id) {
    return Local(
      id: id,
      userRef: json['userRef'] as DocumentReference,
      longitude: json['longitude'] as double,
      latitude: json['latitude'] as double,
      nome: json['nome'] as String,
    );
  }

  // Converte um documento Firestore para um objeto Local
  factory Local.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Local.fromJson(data, doc.reference);
  }
}

class LocalService {
  final CollectionReference _locaisCollection = FirebaseFirestore.instance.collection('locais');

  // Adicionar um novo local
  Future<Local> adicionarLocal(Local local) async {
    // Adiciona o documento e obtém a referência do documento criado
    final docRef = await _locaisCollection.add(local.toJson());
    // Atualiza o objeto Local com o ID do documento
    final localComId = Local(
      id: docRef,
      userRef: local.userRef,
      longitude: local.longitude,
      latitude: local.latitude,
      nome: local.nome,
    );
    // Retorna o objeto Local atualizado com o ID
    return localComId;
  }

  // Obter todos os locais de um usuário específico
  Stream<List<Local>> getLocaisPorUsuario(DocumentReference userRef) {
    return _locaisCollection
        .where('userRef', isEqualTo: userRef) // Usa a referência diretamente
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Local.fromFirestore(doc)).toList());
  }

  // Atualizar um local existente
  Future<void> atualizarLocal(Local local) {
    if (local.id == null) {
      throw ArgumentError('O local deve ter um id definido para atualização.');
    }
    return local.id!.update(local.toJson());
  }

  // Deletar um local
  Future<void> deletarLocal(DocumentReference? localRef) {
    if (localRef == null) {
      throw ArgumentError('A referência do documento não pode ser nula.');
    }
    return localRef.delete();
  }
}

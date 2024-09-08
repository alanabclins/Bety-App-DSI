import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Local {
  DocumentReference? id; // Referência ao documento do local (opcional)
  DocumentReference userRef; // Referência ao documento do usuário
  double longitude;
  double latitude;
  String nome;
  String apelido; // Novo campo

  Local({
    this.id, // O id pode ser nulo até ser atribuído
    required this.userRef,
    required this.longitude,
    required this.latitude,
    required this.nome,
    required this.apelido, // Novo campo
  });

  // Converte um objeto Local para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'userRef': userRef, // Armazena a referência diretamente
      'longitude': longitude,
      'latitude': latitude,
      'nome': nome,
      'apelido': apelido, // Novo campo
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
      apelido: json['apelido'] as String, // Novo campo
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
      apelido: local.apelido, // Novo campo
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

  // Obtém a localização mais próxima ao usuário
  Future<Local?> obterLocalMaisProximo(DocumentReference userRef) async {
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    QuerySnapshot locaisSnapshot = await _locaisCollection
        .where('userRef', isEqualTo: userRef)
        .get();

    List<Local> locais = locaisSnapshot.docs
        .map((doc) => Local.fromFirestore(doc))
        .toList();

    Local? localMaisProximo;
    double? menorDistancia;

    for (Local local in locais) {
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        local.latitude,
        local.longitude,
      );

      if (menorDistancia == null || distance < menorDistancia) {
        menorDistancia = distance;
        localMaisProximo = local;
      }
    }

    return localMaisProximo;
  }
}
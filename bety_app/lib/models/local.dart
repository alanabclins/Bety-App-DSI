import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Local {
  DocumentReference? id;
  DocumentReference userRef;
  double longitude;
  double latitude;
  String nome;
  String apelido;

  Local({
    this.id,
    required this.userRef,
    required this.longitude,
    required this.latitude,
    required this.nome,
    required this.apelido, 
  });

  // Converte um objeto Local para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'userRef': userRef,
      'longitude': longitude,
      'latitude': latitude,
      'nome': nome,
      'apelido': apelido,
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
      apelido: json['apelido'] as String,
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
    final docRef = await _locaisCollection.add(local.toJson());
    final localComId = Local(
      id: docRef,
      userRef: local.userRef,
      longitude: local.longitude,
      latitude: local.latitude,
      nome: local.nome,
      apelido: local.apelido,
    );
    return localComId;
  }

  // Obter todos os locais de um usuário específico
  Stream<List<Local>> getLocaisPorUsuario(DocumentReference userRef) {
    return _locaisCollection
        .where('userRef', isEqualTo: userRef)
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
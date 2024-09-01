import 'package:cloud_firestore/cloud_firestore.dart';

class Glicemia {
  String id;
  double concentracao;
  Timestamp dataHora;
  String tipoMedicao;

  Glicemia({
    required this.id,
    required this.concentracao,
    required this.dataHora,
    required this.tipoMedicao,
  });

  factory Glicemia.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Glicemia(
      id: doc.id,
      concentracao: data['concentracao'],
      dataHora: data['dataHora'],
      tipoMedicao: data['tipoMedicao'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'concentracao': concentracao,
      'dataHora': dataHora,
      'tipoMedicao': tipoMedicao,
    };
  }
}

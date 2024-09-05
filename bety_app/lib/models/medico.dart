import 'package:cloud_firestore/cloud_firestore.dart';

// Classe Medico
class Medico {
  DocumentReference? id; // Referência ao documento do médico (opcional)
  DocumentReference userRef; // Referência ao documento do usuário
  String nome;
  String telefone;
  List<String> especialidades;

  Medico({
    this.id, // O id pode ser nulo até ser atribuído
    required this.userRef,
    required this.nome,
    required this.telefone,
    required this.especialidades,
  });

  // Converte um objeto Medico para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'userRef': userRef, // Armazena a referência diretamente
      'nome': nome,
      'telefone': telefone,
      'especialidades': especialidades,
    };
  }

  // Converte um mapa JSON para um objeto Medico
  factory Medico.fromJson(Map<String, dynamic> json, DocumentReference? id) {
    return Medico(
      id: id,
      userRef: json['userRef'] as DocumentReference,
      nome: json['nome'],
      telefone: json['telefone'],
      especialidades: List<String>.from(json['especialidades']),
    );
  }

  // Converte um documento Firestore para um objeto Medico
  factory Medico.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medico.fromJson(data, doc.reference);
  }
}

// Classe MedicoService para gerenciar os médicos no Firestore
class MedicoService {
  final CollectionReference _medicosCollection =
      FirebaseFirestore.instance.collection('medicos');

  // Lista de especialidades
  static const List<String> especialidades = [
    'Acupunturista',
    'Administrador em Saúde',
    'Alergologista',
    'Anatomopatologista',
    'Anestesiologista',
    'Angiologista',
    'Cardiologista',
    'Cardiologista Pediátrico',
    'Cirurgião Cardiovascular',
    'Cirurgião da Mão',
    'Cirurgião de Cabeça e Pescoço',
    'Cirurgião do Aparelho Digestivo',
    'Cirurgião Geral',
    'Cirurgião Oncológico',
    'Cirurgião Pediátrico',
    'Cirurgião Plástico',
    'Cirurgião Torácico',
    'Cirurgião Urológico',
    'Cirurgião Vascular',
    'Cirurgião Videolaparoscópico',
    'Citopatologista',
    'Clínico Geral',
    'Coloproctologista',
    'Dermatologista',
    'Dermatopatologista',
    'Ecocardiografista',
    'Endocrinologista',
    'Endocrinologista Pediátrico',
    'Endoscopista',
    'Fisiatra (Médico de Reabilitação)',
    'Gastroenterologista',
    'Geriatra',
    'Ginecologista e Obstetra',
    'Ginecologista Oncológico',
    'Hematologista',
    'Hemodinamicista',
    'Hepatologista',
    'Infectologista',
    'Intensivista (Médico de Terapia Intensiva)',
    'Mastologista',
    'Médico de Emergência',
    'Médico de Família e Comunidade',
    'Médico do Esporte',
    'Médico do Trabalho',
    'Médico Legal e Perito',
    'Médico Nuclear',
    'Médico Preventivo e Social',
    'Nefrologista',
    'Neonatologista (Pediatra Neonatal)',
    'Neurocirurgião',
    'Neurofisiologista Clínico',
    'Neurologista',
    'Neuropsiquiatra',
    'Nutrólogo',
    'Oftalmologista',
    'Oncologista',
    'Ortopedista e Traumatologista',
    'Otorrinolaringologista',
    'Paliativista (Médico de Cuidados Paliativos)',
    'Patologista Clínico',
    'Pediatra',
    'Pneumologista',
    'Psiquiatra',
    'Radiologista',
    'Radiologista Intervencionista',
    'Reumatologista',
    'Reumatologista Pediátrico',
    'Transplantologista',
    'Ultrassonografista',
    'Urologista'
  ];

  // Adicionar um novo médico
  Future<Medico> adicionarMedico(Medico medico) async {
    // Adiciona o documento e obtém a referência do documento criado
    final docRef = await _medicosCollection.add(medico.toJson());
    // Atualiza o objeto Medico com o ID do documento
    final medicoComId = Medico(
      id: docRef,
      userRef: medico.userRef,
      nome: medico.nome,
      telefone: medico.telefone,
      especialidades: medico.especialidades,
    );
    // Retorna o objeto Medico atualizado com o ID
    return medicoComId;
  }

  // Obter todos os médicos de um usuário específico com opção de filtro por especialidade
  Stream<List<Medico>> getMedicos(DocumentReference userRef,
      {String? especialidade}) {
    Query query = _medicosCollection.where('userRef', isEqualTo: userRef);

    if (especialidade != null && especialidade.isNotEmpty) {
      query = query.where('especialidades', arrayContains: especialidade);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Medico.fromFirestore(doc)).toList());
  }

  // Atualizar um médico existente
  Future<void> atualizarMedico(Medico medico) async {
    if (medico.id == null) {
      throw ArgumentError('O médico deve ter um id definido para atualização.');
    }
    try {
      await medico.id!.update(medico.toJson());
    } catch (e) {
      print('Erro ao atualizar médico: $e');
      rethrow;
    }
  }

  // Deletar um médico
  Future<void> deletarMedico(DocumentReference? medicoRef) {
    if (medicoRef == null) {
      throw ArgumentError('A referência do documento não pode ser nula.');
    }
    return medicoRef.delete();
  }
}

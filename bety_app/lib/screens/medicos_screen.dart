import 'package:flutter/material.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/models/medico.dart';
import 'package:bety_sprint1/screens/adicionar_medico_screen.dart';
import 'package:bety_sprint1/services/session_service.dart';

class GerenciamentoMedicosPage extends StatefulWidget {
  @override
  _GerenciamentoMedicosPageState createState() =>
      _GerenciamentoMedicosPageState();
}

class _GerenciamentoMedicosPageState extends State<GerenciamentoMedicosPage> {
  String? _especialidadeSelecionada;
  final TextEditingController _especialidadeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = SessionManager().currentUser;

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          mainTitle: 'Gerenciamento de Médicos',
          subtitle: 'Lembre-se do seu melhor medico',
          showLogoutButton: false,
          onBackButtonPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        body: Center(
          child: Text('Usuário não autenticado.'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Gerenciamento de Médicos',
        subtitle: 'Lembre-se do seu melhor medico',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _especialidadeController,
                decoration: InputDecoration(
                  labelText: 'Filtrar por Especialidade',
                  border: OutlineInputBorder(),
                  suffixIcon: PopupMenuButton<String>(
                    icon: Icon(Icons.arrow_drop_down),
                    onSelected: (String value) {
                      setState(() {
                        _especialidadeSelecionada = value;
                        _especialidadeController.text = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return MedicoService.especialidades
                          .map<PopupMenuItem<String>>((String value) {
                        return PopupMenuItem(
                          child: Text(value),
                          value: value,
                        );
                      }).toList();
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _especialidadeSelecionada = value;
                  });
                },
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _especialidadeController.clear();
                  _especialidadeSelecionada = null;
                });
              },
              child: Text('Limpar Filtro'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder<List<Medico>>(
                stream: MedicoService().getMedicos(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar médicos.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum médico encontrado.'));
                  }

                  List<Medico> medicosFiltrados = snapshot.data!;

                  // Filtro por especialidade (digitada ou selecionada)
                  if (_especialidadeSelecionada != null &&
                      _especialidadeSelecionada!.isNotEmpty) {
                    final especialidadeRegExp = RegExp(
                      _especialidadeSelecionada!,
                      caseSensitive: false,
                    );
                    medicosFiltrados = medicosFiltrados.where((medico) {
                      return medico.especialidades.any((especialidade) =>
                          especialidadeRegExp.hasMatch(especialidade));
                    }).toList();
                  }

                  return ListView.builder(
                    itemCount: medicosFiltrados.length,
                    itemBuilder: (context, index) {
                      final medico = medicosFiltrados[index];

                      return Dismissible(
                        key: Key(medico.id?.id ?? ''),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          final bool? confirmed =
                              await _showDeleteDialog(context, medico);
                          return confirmed ?? false;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: const EdgeInsets.all(12.0),
                          elevation: 5,
                          color: Color(0xFF0BAB7C),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              child: Icon(Icons.person,
                                  color: Color(0xFF0BAB7C), size: 30),
                            ),
                            title: Text(
                              medico.nome,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Color(0xFFFAFAFA),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text(
                                  'Telefone: ${medico.telefone}',
                                  style: TextStyle(
                                    color: Color(0xFFFAFAFA),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Especialidades: ${medico.especialidades.join(', ')}',
                                  style: TextStyle(
                                    color: Color(0xFFFAFAFA),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Color(0xFFFAFAFA)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CadastroMedicoPage(
                                      userRef: user.uid,
                                      medico: medico,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CadastroMedicoPage(userRef: user.uid),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Cadastrar Médico'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0BAB7C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, Medico medico) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Médico'),
        content:
            Text('Tem certeza que deseja excluir o médico ${medico.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (medico.id != null) {
                await MedicoService().deletarMedico(medico.id);
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

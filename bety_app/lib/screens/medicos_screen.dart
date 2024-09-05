import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bety_sprint1/models/medico.dart';
import 'package:bety_sprint1/screens/adicionar_medico_screen.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:intl/intl.dart'; // para formatar datas

class GerenciamentoMedicosPage extends StatefulWidget {
  @override
  _GerenciamentoMedicosPageState createState() =>
      _GerenciamentoMedicosPageState();
}

class _GerenciamentoMedicosPageState extends State<GerenciamentoMedicosPage> {
  String? _especialidadeSelecionada;

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Filtrar por Especialidade',
                border: OutlineInputBorder(),
              ),
              value: _especialidadeSelecionada,
              items: MedicoService.especialidades
                  .map((especialidade) => DropdownMenuItem(
                        child: Text(especialidade),
                        value: especialidade,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _especialidadeSelecionada = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Medico>>(
              stream: MedicoService().getMedicos(user.uid,
                  especialidade: _especialidadeSelecionada),
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

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final medico = snapshot.data![index];

                    return Dismissible(
                      key: Key(medico.id?.id ??
                          ''), // Acessa o ID do DocumentReference como String
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
                        elevation: 5, // Adiciona sombra ao card
                        color: Color(0xFF0BAB7C), // Cor de fundo do card
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
                              color: Color(0xFFFAFAFA), // Cor do texto
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                'Telefone: ${medico.telefone}',
                                style: TextStyle(
                                  color: Color(0xFFFAFAFA), // Cor do texto
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Especialidades: ${medico.especialidades.join(', ')}',
                                style: TextStyle(
                                  color: Color(0xFFFAFAFA), // Cor do texto
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit,
                                color: Color(
                                    0xFFFAFAFA)), // Cor do ícone de edição
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
                    builder: (context) => CadastroMedicoPage(userRef: user.uid),
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
                // Chama o método deletarMedico passando a referência correta
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

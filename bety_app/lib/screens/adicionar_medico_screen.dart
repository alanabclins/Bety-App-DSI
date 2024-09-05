import 'package:flutter/material.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/models/medico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class CadastroMedicoPage extends StatefulWidget {
  final DocumentReference userRef;
  final Medico? medico;

  CadastroMedicoPage({required this.userRef, this.medico});

  @override
  _CadastroMedicoPageState createState() => _CadastroMedicoPageState();
}

class _CadastroMedicoPageState extends State<CadastroMedicoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final MaskedTextController _telefoneController =
      MaskedTextController(mask: '(00) 00000-0000');
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedEspecialidades = [];
  List<String> _filteredEspecialidades = MedicoService.especialidades;

  @override
  void initState() {
    super.initState();
    if (widget.medico != null) {
      _nomeController.text = widget.medico!.nome;
      _telefoneController.text = widget.medico!.telefone;
      _selectedEspecialidades = widget.medico!.especialidades;
    }

    _searchController.addListener(_filterEspecialidades);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterEspecialidades() {
    setState(() {
      _filteredEspecialidades = MedicoService.especialidades
          .where((especialidade) => especialidade
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _salvarMedico() async {
    if (_formKey.currentState!.validate()) {
      final medico = Medico(
        userRef: widget.userRef,
        nome: _nomeController.text,
        telefone: _telefoneController.text,
        especialidades: _selectedEspecialidades,
        id: widget.medico?.id,
      );

      if (widget.medico == null) {
        await MedicoService().adicionarMedico(medico);
      } else {
        await MedicoService().atualizarMedico(medico);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: widget.medico == null ? 'Adicionar Médico' : 'Editar Médico',
        subtitle: widget.medico == null
            ? 'Insira as informações do médico'
            : 'Edite as informações do médico',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        color: const Color.fromARGB(255, 251, 250, 243),
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 199, 244, 194),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do médico.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _telefoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 199, 244, 194),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone do médico.';
                  } else if (!_telefoneController.text
                      .contains(RegExp(r'^\(\d{2}\) \d{5}-\d{4}$'))) {
                    return 'Por favor, insira um número de telefone válido no formato (00) 00000-0000.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Pesquisar Especialidades',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 199, 244, 194),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF0BAB7C)),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: _filteredEspecialidades.map((especialidade) {
                    return CheckboxListTile(
                      title: Text(especialidade),
                      value: _selectedEspecialidades.contains(especialidade),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedEspecialidades.add(especialidade);
                          } else {
                            _selectedEspecialidades.remove(especialidade);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 150),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvarMedico,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0BAB7C),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    widget.medico == null ? 'Salvar' : 'Atualizar',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/models/glicemia.dart';
import 'package:bety_sprint1/screens/add_glicemia_record_screen.dart';
import 'package:bety_sprint1/services/session_service.dart';

class MedicaoGlicoseScreen extends StatefulWidget {
  const MedicaoGlicoseScreen();

  @override
  _MedicaoGlicoseScreenState createState() => _MedicaoGlicoseScreenState();
}

class _MedicaoGlicoseScreenState extends State<MedicaoGlicoseScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  final GlicemiaService _glicemiaService = GlicemiaService();

  Future<bool?> _confirmDeleteRecord(dynamic glicemiaRef) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza de que deseja excluir este registro?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Excluir'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _glicemiaService.deletarGlicemia(glicemiaRef);
    }

    return confirmed;
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedDate = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _searchController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionManager().currentUser;

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          mainTitle: 'Registro de Glicemia',
          subtitle: 'Gerencie suas medições de glicemia',
          showLogoutButton: false,
          onBackButtonPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        body: const Center(
          child: Text('Usuário não autenticado.'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Registro de Glicemia',
        subtitle: 'Gerencie suas medições de glicemia',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Buscar por data',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        _selectDate(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: StreamBuilder<List<Glicemia>>(
                stream: _glicemiaService.getGlicemiasPorUsuario(user.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Glicemia> records = snapshot.data!;

                  if (_selectedDate != null) {
                    records = records.where((record) {
                      final recordDate = record.dataHora.toDate();
                      return recordDate.year == _selectedDate!.year &&
                          recordDate.month == _selectedDate!.month &&
                          recordDate.day == _selectedDate!.day;
                    }).toList();
                  }

                  if (records.isEmpty) {
                    return Center(
                      child: Text(_selectedDate == null
                          ? 'Nenhum registro encontrado.'
                          : 'Não há registros para o dia ${_searchController.text}.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final glicemia = records[index];

                      return Dismissible(
                        key: Key(glicemia.id!.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          final bool? confirmed = await _confirmDeleteRecord(glicemia.id!);
                          return confirmed; // Retorna verdadeiro para realmente deletar, falso para cancelar
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
                          color: const Color(0xFF0BAB7C),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data: ${DateFormat('dd/MM/yyyy').format(glicemia.dataHora.toDate())}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Hora: ${DateFormat('HH:mm').format(glicemia.dataHora.toDate())}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Concentração: ${glicemia.concentracao} mg/dL',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tipo de Medição: ${glicemia.tipoMedicao}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddGlicemiaRecordScreen(glicemia: glicemia),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddGlicemiaRecordScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Registro de Glicemia'),
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
}

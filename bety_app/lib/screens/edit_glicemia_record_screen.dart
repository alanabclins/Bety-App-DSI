import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bety_sprint1/services/auth_service.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';

class EditGlicemiaRecordScreen extends StatefulWidget {
  final User user;
  final String recordId;
  final Map<String, dynamic> recordData;

  const EditGlicemiaRecordScreen({
    Key? key,
    required this.user,
    required this.recordId,
    required this.recordData,
  }) : super(key: key);

  @override
  _EditGlicemiaRecordScreenState createState() =>
      _EditGlicemiaRecordScreenState();
}

class _EditGlicemiaRecordScreenState extends State<EditGlicemiaRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  late String _selectedMeasurementType;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime =
        (widget.recordData['dataHora'] as Timestamp).toDate();
    _glucoseController.text =
        widget.recordData['concentracao'].toString();
    _selectedMeasurementType = widget.recordData['tipoMedicao'];
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await AuthService().atualizarRegistroGlicemia(
        userId: widget.user.uid,
        recordId: widget.recordId,
        concentracao: double.parse(_glucoseController.text),
        dataHora: _selectedDateTime,
        tipoMedicao: _selectedMeasurementType,
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDeleteRecord() async {
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
      await AuthService().excluirRegistroGlicemia(
        userId: widget.user.uid,
        recordId: widget.recordId,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Editar Registro',
        subtitle: 'Atualize os detalhes da medição',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Data e Hora',
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.grey[200],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF0BAB7C)),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today,
                        color: Color(0xFF0BAB7C)),
                    onPressed: () {
                      _selectDateTime(context);
                    },
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text:
                      DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _glucoseController,
                decoration: InputDecoration(
                  labelText: 'Concentração de glicemia (mg/dL)',
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.grey[200],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF0BAB7C)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a concentração de glicemia';
                  }
                  final double? glucoseValue = double.tryParse(value);
                  if (glucoseValue == null || glucoseValue <= 0) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMeasurementType,
                decoration: InputDecoration(
                  labelText: 'Tipo de medição',
                  labelStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.grey[200],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF0BAB7C)),
                  ),
                ),
                items: ['Jejum', 'Pós-prandial', 'Aleatória']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMeasurementType = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0BAB7C),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _confirmDeleteRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Excluir Registro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

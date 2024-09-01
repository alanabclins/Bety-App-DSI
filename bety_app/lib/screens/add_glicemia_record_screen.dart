import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bety_sprint1/services/auth_service.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';

class AddGlicemiaRecordScreen extends StatefulWidget {
  final User user;

  const AddGlicemiaRecordScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AddGlicemiaRecordScreenState createState() => _AddGlicemiaRecordScreenState();
}

class _AddGlicemiaRecordScreenState extends State<AddGlicemiaRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  String _selectedMeasurementType = 'Jejum';
  DateTime _selectedDateTime = DateTime.now();

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
      await AuthService().adicionarRegistroGlicemia(
        userId: widget.user.uid,
        concentracao: double.parse(_glucoseController.text),
        dataHora: _selectedDateTime,
        tipoMedicao: _selectedMeasurementType,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Adicionar Registro',
        subtitle: 'Insira os detalhes da medição',
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
                    borderSide: const BorderSide(color: Color(0xFF0BAB7C)),
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
                  text: DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime),
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
                    borderSide: const BorderSide(color: Color(0xFF0BAB7C)),
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
                    borderSide: const BorderSide(color: Color(0xFF0BAB7C)),
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bety_sprint1/services/auth_service.dart';

class MedicaoGlicoseScreen extends StatefulWidget {
  const MedicaoGlicoseScreen({super.key, required this.user, required this.userData});
  final User user;
  final Map <String, dynamic> userData; 

  @override
  _MedicaoGlicoseScreenState createState() => _MedicaoGlicoseScreenState();
}

class _MedicaoGlicoseScreenState extends State<MedicaoGlicoseScreen> {
  final List<Map<String, dynamic>> _glucoseRecords = [];
  final TextEditingController _searchController = TextEditingController();

  void _addRecord(Map<String, dynamic> newRecord) {
    setState(() {
      _glucoseRecords.add(newRecord);
    });
  }

  void _deleteRecord(int index) {
    setState(() {
      _glucoseRecords.removeAt(index);
    });
  }

  List<Map<String, dynamic>> _filteredRecords() {
    if (_searchController.text.isEmpty) {
      return _glucoseRecords;
    }
    return _glucoseRecords
        .where((record) =>
            record['date'].toString().contains(_searchController.text))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Registro de Glicemia',
        subtitle: 'Registre suas medições de glicemia!',
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
              decoration: InputDecoration(
                labelText: 'Buscar por data',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: ListView.builder(
                itemCount: _filteredRecords().length,
                itemBuilder: (context, index) {
                  final record = _filteredRecords()[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.lightGreen[100],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.green[800],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  record['date'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Text(
                                'Medição realizada às ${record['time']}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14.4,
                                  fontWeight: FontWeight.w700,
                                  height: 17.28 /
                                      14.4, // line-height divided by font-size
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => _deleteRecord(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                              'Concentração de glicose: ${record['glucose']} mg/dL'),
                          const SizedBox(height: 8),
                          Text(
                              'Tipo de medição: ${record['measurementType']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecordScreen(onSubmit: _addRecord),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFF0BAB7C),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class AddRecordScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddRecordScreen({super.key, required this.onSubmit});

  @override
  _AddRecordScreenState createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _glucoseController = TextEditingController();
  String _selectedMeasurementType = 'Jejum';

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('HH:mm').format(
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'date': _dateController.text,
        'time': _timeController.text,
        'glucose': int.parse(_glucoseController.text),
        'measurementType': _selectedMeasurementType,
      });
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
          child: Column(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Data',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF0BAB7C)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, color: Color(0xFF0BAB7C)),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Hora',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF0BAB7C)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time, color: Color(0xFF0BAB7C)),
                    onPressed: () {
                      _selectTime(context);
                    },
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a hora';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _glucoseController,
                decoration: InputDecoration(
                  labelText: 'Concentração de glicose (mg/dL)',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF0BAB7C)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a concentração de glicose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMeasurementType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Medição',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF0BAB7C)),
                  ),
                ),
                items: ['Jejum', 'Pós-prandial', 'Aleatório']
                    .map((String type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedMeasurementType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Adicionar Registro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BAB7C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MedicaoGlicoseScreen(),
    );
  }
}

class MedicaoGlicoseScreen extends StatefulWidget {
  const MedicaoGlicoseScreen({super.key});

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
                        Text('Tipo de medição: ${record['measurementType']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ) // contrained fecha aqui
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddRecordDialog(onSubmit: _addRecord);
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFF0BAB7C),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class AddRecordDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddRecordDialog({super.key, required this.onSubmit});

  @override
  _AddRecordDialogState createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<AddRecordDialog> {
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
    return AlertDialog(
      title: const Text('Adicionar Registro'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Data',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
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
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Hora',
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
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
            TextFormField(
              controller: _glucoseController,
              decoration: const InputDecoration(
                  labelText: 'Concentração de glicose (mg/dL)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a concentração de glicose';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedMeasurementType,
              decoration: const InputDecoration(labelText: 'Tipo de medição'),
              items: [
                'Jejum',
                'Antes das refeições',
                'Após as refeições',
                'Antes de dormir',
                'Ao acordar'
              ].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMeasurementType = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

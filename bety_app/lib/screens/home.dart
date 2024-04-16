import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bety',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bety'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Medicamentos Registrados:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            MedicationCard(
              medicationName: 'Medicamento xxx',
              medicationCode: 'xxx',
              medicationTime: 'xxx',
            ),
            MedicationCard(
              medicationName: 'Medicamento xxx',
              medicationCode: 'xxx',
              medicationTime: 'xxx',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notas sobre pessoa:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Implement edit functionality
                    },
                    child: Text('Editar'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Medições de glicemia recentes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            GlucoseMeasurementCard(
              glucoseConcentration: 'xxx',
              dosage: 'xx',
              measurementDate: 'xx/xx/xxxx',
              measurementTime: 'xx.xx',
            ),
            GlucoseMeasurementCard(
              glucoseConcentration: 'xxx',
              dosage: 'xx',
              measurementDate: 'xx/xx/xxxx',
              measurementTime: 'xx.xx',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final String medicationName;
  final String medicationCode;
  final String medicationTime;

  const MedicationCard({
    required this.medicationName,
    required this.medicationCode,
    required this.medicationTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medicamento: $medicationName'),
            Text('Código: $medicationCode'),
            Text('Horário: $medicationTime'),
          ],
        ),
      ),
    );
  }
}

class GlucoseMeasurementCard extends StatelessWidget {
  final String glucoseConcentration;
  final String dosage;
  final String measurementDate;
  final String measurementTime;

  const GlucoseMeasurementCard({
    required this.glucoseConcentration,
    required this.dosage,
    required this.measurementDate,
    required this.measurementTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Concentração de glicose: $glucoseConcentration'),
            Text('Dosagem: $dosage'),
            Text('Data da medição: $measurementDate'),
            Text('Horário: $measurementTime'),
          ],
        ),
      ),
    );
  }
}
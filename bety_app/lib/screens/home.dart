import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bety',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bety'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Medicamentos Registrados:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildMedicationCarousel(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notas sobre pessoa:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Implement edit functionality
                    },
                    child: const Text('Editar'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Medições de glicemia recentes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildGlucoseMeasurementCarousel(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Message',
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        fixedColor: Colors.green,
        backgroundColor: Colors.grey,
      ),
    );
  }

  Widget _buildMedicationCarousel() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2, // Number of medication cards
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: MedicationCard(
              medicationName: 'Dipirona',
              medicationCode: 'xxx',
              medicationTime: 'xxx',
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlucoseMeasurementCarousel() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2, // Number of glucose measurement cards
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: GlucoseMeasurementCard(
              glucoseConcentration: 'xxx',
              dosage: 'xx',
              measurementDate: 'xx/xx/xxxx',
              measurementTime: 'xx.xx',
            ),
          );
        },
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final String medicationName;
  final String medicationCode;
  final String medicationTime;

  const MedicationCard({
    super.key,
    required this.medicationName,
    required this.medicationCode,
    required this.medicationTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFB2D8B2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Medicamento: $medicationName',
              style: const TextStyle(color: Color(0xFF005739)),
              textAlign: TextAlign.center,
            ),
            Text(
              'Código: $medicationCode',
              style: const TextStyle(color: Color(0xFF005739)),
              textAlign: TextAlign.center,
            ),
            Text(
              'Horário: $medicationTime',
              style: const TextStyle(color: Color(0xFF005739)),
              textAlign: TextAlign.center,
            ),
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
    super.key,
    required this.glucoseConcentration,
    required this.dosage,
    required this.measurementDate,
    required this.measurementTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFB2D8B2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Concentração de glicose: $glucoseConcentration',
              style: const TextStyle(color: Color(0xFF005739)),
              textAlign: TextAlign.center,
            ),
            Text(
              'Dosagem: $dosage',
              style: const TextStyle(color: Color(0xFF005739)),
              textAlign: TextAlign.center,
            ),
            Text(
              'Data da medição: $measurementDate',
              style: const TextStyle(color: Color(0xFF005739)),
              textAlign: TextAlign.center,
            ),
            Text(
              'Horário: $measurementTime',
              style: const TextStyle(color: Color(0xFF005739)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

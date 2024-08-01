import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HelpPointPage(),
    );
  }
}

class HelpPointPage extends StatefulWidget {
  @override
  _HelpPointPageState createState() => _HelpPointPageState();
}

class _HelpPointPageState extends State<HelpPointPage> {
  final MapController _mapController = MapController();
  final List<LatLng> _savedPoints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ponto de ajuda'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navegar de volta
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green,
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bety',
                  style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Ponto de ajuda',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Informações pessoais',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(40.7128, -74.0060), // Coordenadas de Nova York
                zoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _savedPoints.add(point);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _savedPoints.map((point) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: point,
                      builder: (ctx) => Container(
                        child: Icon(Icons.location_on, color: Colors.red, size: 40.0),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Implementar cálculo de rota aqui
              },
              child: Text('Calcular Rota'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificações',
          ),
        ],
        selectedItemColor: Colors.green,
      ),
    );
  }
}

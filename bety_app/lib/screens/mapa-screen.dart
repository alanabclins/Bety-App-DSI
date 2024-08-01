import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';

class MapaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Demo',
      debugShowCheckedModeBanner: false,
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
      appBar: CustomAppBar(
        mainTitle: 'Mapa',
        subtitle: 'Ponto de ajuda',
        showLogoutButton: false,
        onBackButtonPressed: () {
          //TO DO: Implementar ação para voltar
          Navigator.pushNamed(context, '/home');
        },
      ),
      body: Column(
        children: [
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
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _savedPoints.map((point) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: point,
                      builder: (ctx) => Container(
                        child: Icon(Icons.location_on,
                            color: Colors.red, size: 40.0),
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
    );
  }
}

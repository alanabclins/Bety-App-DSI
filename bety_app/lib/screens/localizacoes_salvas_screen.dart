import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bety_sprint1/models/local.dart'; // Modelo Local
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/models/user.dart';

class LocalizacoesSalvasScreen extends StatefulWidget {
  @override
  _LocalizacoesSalvasScreenState createState() => _LocalizacoesSalvasScreenState();
}

class _LocalizacoesSalvasScreenState extends State<LocalizacoesSalvasScreen> {
  User? _currentUser;
  LatLng? _currentLocation;
  final LocalService _localService = LocalService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation();
  }

  Future<void> _loadUserData() async {
    // Carrega o usuário atual da sessão
    _currentUser = SessionManager().currentUser;
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) / 1000; // Retorna a distância em quilômetros
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null || _currentLocation == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Localizações Salvas')),
        body: Center(child: CircularProgressIndicator()), // Exibe um loading enquanto carrega os dados do usuário e a localização atual
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Localizações Salvas')),
      body: StreamBuilder<List<Local>>(
        stream: _localService.getLocaisPorUsuario(_currentUser!.uid), // Obtém os locais do usuário logado
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Exibe um loading enquanto carrega os locais
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma localização salva.'));
          }

          final locais = snapshot.data!;

          return ListView.builder(
            itemCount: locais.length,
            itemBuilder: (context, index) {
              final local = locais[index];
              final distancia = _calculateDistance(
                _currentLocation!,
                LatLng(local.latitude, local.longitude),
              );

              return ListTile(
                title: Text(local.nome),
                subtitle: Text(
                  'Lat: ${local.latitude}, Lng: ${local.longitude}\nDistância: ${distancia.toStringAsFixed(2)} km',
                ),
                onTap: () {
                  // Retorna o local selecionado para a tela anterior
                  Navigator.pop(context, LatLng(local.latitude, local.longitude));
                },
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MapaScreen());

class MapaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapaPage(),
    );
  }
}

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = LatLng(-8.0476, -34.8763); // Ponto inicial do mapa
  LatLng? _currentPosition;
  LatLng _savedPoint = LatLng(-8.0476, -34.8763); // Ponto salvo
  double? _distance;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviço de localização desabilitado.');
    }

    // Verifica o status da permissão de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissão de localização negada permanentemente.');
    }

    // Se a permissão foi concedida, obtenha a localização atual
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _calculateDistance();
    });
  }

  void _calculateDistance() {
    if (_currentPosition != null) {
      final double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _savedPoint.latitude,
        _savedPoint.longitude,
      );
      setState(() {
        _distance = distance;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa com Localização")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15.0,
        ),
        markers: {
          if (_currentPosition != null)
            Marker(
              markerId: MarkerId('currentPosition'),
              position: _currentPosition!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          Marker(
            markerId: MarkerId('savedPoint'),
            position: _savedPoint,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          if (_currentPosition != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(_currentPosition!),
            );
          }
        },
      ),
      floatingActionButton: _distance != null
          ? FloatingActionButton.extended(
              label: Text("${_distance!.toStringAsFixed(2)} metros"),
              icon: Icon(Icons.directions),
              onPressed: () {},
            )
          : null,
    );
  }
}

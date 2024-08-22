import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:bety_sprint1/utils/custom_app_bar.dart'; // Certifique-se de que essa linha está correta para o caminho do CustomAppBar

class MapaScreen extends StatefulWidget {
  final User user;

  const MapaScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;
  LatLng? _savedLocation;
  final TextEditingController _addressController = TextEditingController();
  String? _savedAddress;
  double? _distanceToSavedLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadSavedLocation();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _loadSavedLocation() async {
    final userId = widget.user.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('usuarios').doc(userId).get();
    
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      
      if (data.containsKey('saved_location')) {
        LatLng savedLatLng = LatLng(
          data['saved_location']['latitude'],
          data['saved_location']['longitude'],
        );

        // Converte as coordenadas em um endereço legível
        List<Placemark> placemarks = await placemarkFromCoordinates(
            savedLatLng.latitude, savedLatLng.longitude);

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          String fullAddress =
              '${placemark.street}, ${placemark.locality}, ${placemark.country}';
          
          // Atualiza o controlador da barra de pesquisa com o endereço
          setState(() {
            _addressController.text = fullAddress;
            _savedLocation = savedLatLng;
            _savedAddress = fullAddress;
          });
        }
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  Future<void> _updateSavedAddressAndDistance(LatLng location) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      setState(() {
        _savedAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        _addressController.text = _savedAddress!;
      });
    }

    _calculateDistanceToSavedLocation();
  }

  void _calculateDistanceToSavedLocation() {
    if (_currentLocation != null && _savedLocation != null) {
      double distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _savedLocation!.latitude,
        _savedLocation!.longitude,
      );
      setState(() {
        _distanceToSavedLocation = distance / 1000; // Convertendo para km
      });
    }
  }

  Future<void> _searchAddress() async {
    try {
      List<Location> locations = await locationFromAddress(_addressController.text);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng latLng = LatLng(location.latitude, location.longitude);
        _updateLocation(latLng);
        mapController.animateCamera(
          CameraUpdate.newLatLng(latLng),
        );
        _updateSavedAddressAndDistance(latLng);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Endereço não encontrado!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar endereço: $e')),
      );
    }
  }

  void _updateLocation(LatLng location) {
    setState(() {
      _savedLocation = location;
    });
    _saveLocation(location);
  }

  void _saveLocation(LatLng location) async {
    final userId = widget.user.uid;

    await FirebaseFirestore.instance.collection('usuarios').doc(userId).update({
      'saved_location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Localização salva com sucesso!')),
    );

    _updateSavedAddressAndDistance(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar( // Custom AppBar
        mainTitle: 'Mapa',
        subtitle: 'Explore e Salve Locais',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? LatLng(0, 0),
                zoom: 11.0,
              ),
              markers: {
                if (_savedLocation != null)
                  Marker(
                    markerId: MarkerId('savedLocation'),
                    position: _savedLocation!,
                    infoWindow: InfoWindow(
                      title: 'Localização Salva',
                      snippet: _savedAddress ?? 'Endereço não disponível',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                if (_currentLocation != null)
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: _currentLocation!,
                    infoWindow: InfoWindow(
                      title: 'Sua Localização',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
              },
              onTap: (LatLng location) {
                _updateLocation(location);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Digite um endereço',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchAddress,
                ),
              ),
            ),
          ),
          if (_distanceToSavedLocation != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Distância até o local salvo: ${_distanceToSavedLocation!.toStringAsFixed(2)} km'),
            ),
          if (_savedLocation != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  title: Text('Localização Salva'),
                  subtitle: Text(_savedAddress ?? 'Endereço não disponível'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _addressController.text = _savedAddress ?? '';
                      FocusScope.of(context).requestFocus(FocusNode()); // Abre o teclado
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

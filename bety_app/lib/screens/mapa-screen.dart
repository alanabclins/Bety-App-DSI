import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/models/user.dart';
import 'package:bety_sprint1/models/local.dart';
import 'package:bety_sprint1/screens/localizacoes_salvas_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;
  LatLng? _savedLocation;
  final TextEditingController _addressController = TextEditingController();
  String? _savedAddress;
  String? _savedLocationName;
  double? _distanceToSavedLocation;
  User? _currentUser;
  bool _isEditing = false;
  
  final LocalService _localService = LocalService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getLocationStream();
  }

  Future<void> _loadUserData() async {
    _currentUser = SessionManager().currentUser;

    if (_currentUser != null) {
      _localService.getLocaisPorUsuario(_currentUser!.uid).first.then((locais) {
        if (locais.isNotEmpty) {
          final local = locais.first;
          setState(() {
            _savedLocation = LatLng(local.latitude, local.longitude);
            _addressController.text = '${_savedLocation!.latitude}, ${_savedLocation!.longitude}';
          });
          _updateSavedAddressAndDistance(_savedLocation!);
        }
      });
    }
  }

  void _getLocationStream() {
    Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high))
        .listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _calculateDistanceToSavedLocation();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentLocation != null) {
      // A câmera não é centralizada automaticamente agora
    }
  }

  Future<void> _updateSavedAddressAndDistance(LatLng location) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      setState(() {
        _savedAddress = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        _savedLocationName = _savedAddress;
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
        _distanceToSavedLocation = distance / 1000;
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
        await _updateSavedAddressAndDistance(latLng);
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
  }

  void _saveLocation() async {
    if (_currentUser != null && _savedLocation != null) {
      final local = Local(
        userRef: _currentUser!.uid,
        latitude: _savedLocation!.latitude,
        longitude: _savedLocation!.longitude,
        nome: _savedLocationName ?? 'Local salvo',
      );
      await _localService.adicionarLocal(local);
      await SessionManager().updateUserInSession();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Localização salva com sucesso!')),
      );
    }
  }

  void _centerMapOnCurrentLocation() {
    if (_currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mapa')),
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
                      title: _savedLocationName ?? 'Localização Salva',
                      snippet: _savedAddress ?? 'Endereço não disponível',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
                if (_currentLocation != null)
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: _currentLocation!,
                    infoWindow: InfoWindow(
                      title: 'Sua Localização Atual',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
                  icon: Icon(_isEditing ? Icons.check : Icons.search),
                  onPressed: () {
                    if (_isEditing) {
                      _saveLocation();
                      setState(() {
                        _isEditing = false;
                      });
                    } else {
                      _searchAddress();
                    }
                  },
                ),
              ),
              onTap: () {
                setState(() {
                  _isEditing = true;
                });
              },
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
                  title: Text(_isEditing ? 'Editando...' : 'Localização Salva'),
                  subtitle: _isEditing
                      ? TextField(
                          controller: _addressController,
                          onSubmitted: (_) {
                            _saveLocation();
                            setState(() {
                              _isEditing = false;
                            });
                          },
                        )
                      : Text(_savedAddress ?? 'Endereço não disponível'),
                  trailing: _isEditing
                      ? IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            _saveLocation();
                            setState(() {
                              _isEditing = false;
                            });
                          },
                        )
                      : null,
                  onTap: () {
                    if (_currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocalizacoesSalvasScreen(),
                        ),
                      ).then((selectedLocation) {
                        if (selectedLocation != null && selectedLocation is LatLng) {
                          _updateLocation(selectedLocation);
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          // Adicionando um botão para centralizar o mapa na localização atual
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.my_location),
              label: Text('Centralizar no Local Atual'),
              onPressed: _centerMapOnCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }
}
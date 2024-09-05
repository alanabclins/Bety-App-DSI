import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/models/user.dart';
import 'package:bety_sprint1/models/local.dart';
import 'package:bety_sprint1/screens/localizacoes_salvas_screen.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';  // Certifique-se de importar o CustomAppBar

class MapaScreen extends StatefulWidget {
  const MapaScreen();

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;
  LatLng? _savedLocation;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  String? _savedAddress;
  String? _savedLocationName;
  double? _distanceToSavedLocation;
  User? _currentUser;
  final LocalService _localService = LocalService();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verifica se a localização atual está disponível e centraliza o mapa
    if (_currentLocation != null) {
      _centerMapOnCurrentLocation();
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissão negada. Mostre um alerta ou faça algo apropriado.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de localização foi negada')),
        );
        return;
      }
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // Permissão concedida
      _getLocationStream();
      _centerMapOnCurrentLocation();
    }
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

  void _saveLocation(String nickname) async {
    if (_currentUser != null && _savedLocation != null) {
      final local = Local(
        userRef: _currentUser!.uid,
        latitude: _savedLocation!.latitude,
        longitude: _savedLocation!.longitude,
        nome: _savedLocationName ?? 'Localização Salva',
        apelido: nickname,
      );
      await _localService.adicionarLocal(local);
      await SessionManager().updateUserInSession();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Localização salva com sucesso!')),
      );
    }
  }

  void _centerMapOnSavedLocation() {
    if (_savedLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(_savedLocation!),
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

  void _showSaveLocationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Você deseja salvar a localização?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Digite um apelido para a localização',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey, // Cor para o botão de cancelar
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String nickname = _nicknameController.text.trim();
              if (nickname.isNotEmpty) {
                Navigator.pop(context);
                _saveLocation(nickname);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor, insira um apelido.')),
                );
              }
            },
            child: Text('Salvar'),
          ),
        ],
      );
    },
  );

  
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Mapa',
        subtitle: 'Visualize e salve locais',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
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
                  icon: Icon(Icons.search),  // Mantém sempre o ícone de lupa
                  onPressed: () {
                    _searchAddress();  // Chama a função de busca diretamente
                  },
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
                  color: Color(0xFF0BAB7C), // Cor de fundo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Borda arredondada
                  ),
                  child: ListTile(
                    title: Text(_savedLocationName ?? 'Localização Salva', style: TextStyle(color: Color(0xFFFBFAF3))), // Cor do texto
                    subtitle: Text('Clique aqui para ver todas suas localizações', style: TextStyle(color: Color(0xFFFBFAF3))), // Cor do texto
                    trailing: IconButton(
                      icon: Icon(Icons.my_location, color: Color(0xFFFBFAF3)), // Cor do ícone
                      onPressed: _centerMapOnSavedLocation, // Centraliza o mapa na localização salva
                    ),
                    onTap: () {
                      if (_currentUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocalizacoesSalvasScreen(),
                          ),
                        ).then((result) {
                          if (result != null) {
                            LatLng selectedLocation = result['location'];
                            String selectedName = result['name'];
                            _updateLocation(selectedLocation); 
                            _savedLocationName = selectedName;
                          }
                        });
                      }
                    },
                  ),
                ),
              ),


            Padding(
            padding: const EdgeInsets.all(8.0),
            child: FractionallySizedBox(
              widthFactor: 0.98, // Ajusta a largura para 90% da largura do pai
              child: ElevatedButton.icon(
                icon: Icon(Icons.my_location, color: Color(0xFFFBFAF3)), // Cor do ícone
                label: Text('Centralizar no Local Atual', style: TextStyle(color: Color(0xFFFBFAF3))), // Cor do texto
                onPressed: _centerMapOnCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BAB7C), // Cor de fundo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Borda arredondada
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FractionallySizedBox(
              widthFactor: 0.98, // Ajusta a largura para 90% da largura do pai
              child: ElevatedButton(
                onPressed: _showSaveLocationDialog,
                child: Text('Salvar', style: TextStyle(color: Color(0xFFFBFAF3))), // Cor do texto
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BAB7C), // Cor de fundo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Borda arredondada
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
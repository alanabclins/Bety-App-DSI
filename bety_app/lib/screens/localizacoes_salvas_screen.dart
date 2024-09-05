import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bety_sprint1/models/local.dart'; // Modelo Local
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/models/user.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart'; // Importa o CustomAppBar

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
    _currentUser = SessionManager().currentUser;
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível obter a localização.')),
      );
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) / 1000; // Retorna a distância em quilômetros
  }

  void _editLocationName(Local local) async {
    final TextEditingController _nameController = TextEditingController(text: local.nome);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Nome do Local'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nome'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  local.nome = _nameController.text;
                  await _localService.atualizarLocal(local);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Nome do local atualizado com sucesso!')),
                  );
                  setState(() {});
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
    if (_currentUser == null || _currentLocation == null) {
      return Scaffold(
        appBar: CustomAppBar(
          mainTitle: 'Localizações Salvas',
          subtitle: '',
          showLogoutButton: false,
          onBackButtonPressed: () {
            Navigator.pushNamed(context, '/mapa');
          },
        ),
        body: Center(child: CircularProgressIndicator()), // Exibe um loading enquanto carrega os dados do usuário e a localização atual
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Localizações Salvas',
        subtitle: 'Veja suas localizações salvas',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
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
          // Ordena a lista de locais pela distância
          locais.sort((a, b) {
            double distanceA = _calculateDistance(
              _currentLocation!,
              LatLng(a.latitude, a.longitude),
            );
            double distanceB = _calculateDistance(
              _currentLocation!,
              LatLng(b.latitude, b.longitude),
            );
            return distanceA.compareTo(distanceB);
          });

          return ListView.builder(
            itemCount: locais.length,
            itemBuilder: (context, index) {
              final local = locais[index];
              final distancia = _calculateDistance(
                _currentLocation!,
                LatLng(local.latitude, local.longitude),
              );

              return Dismissible(
              key: Key(local.id!.id), // Use um identificador único para cada local
              direction: DismissDirection.endToStart, // Permite swipe da direita para esquerda
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                await _localService.deletarLocal(local.id); // Chama a função que você me enviou
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${local.nome} foi deletado.')),
                );
                setState(() {}); // Atualiza a tela após a exclusão
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: const EdgeInsets.all(12.0),
                color: const Color(0xFF0BAB7C), // Cor do Card
                child: ListTile(
                  title: Text(
                    local.apelido, // Apelido do local
                    style: TextStyle(color: Colors.white), // Cor do texto para combinar com o card
                  ),
                  subtitle: Text(
                    '${local.nome}\nDistância: ${distancia.toStringAsFixed(2)} km', // Nome do local e distância
                    style: TextStyle(color: Colors.white70), // Cor do subtítulo
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _editLocationName(local), // Abre o campo de texto para editar o nome do local
                  ),
                  onTap: () {
                    // Retorna o local selecionado para a tela anterior
                    Navigator.pop(context, {
                      'location': LatLng(local.latitude, local.longitude),
                      'name': local.nome,
                    });
                  },
                ),
              ),
            );
            },
          );
        },
      ),
    );
  }
}
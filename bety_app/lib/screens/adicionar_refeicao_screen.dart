import 'package:flutter/material.dart';
import 'package:bety_sprint1/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/utils/alert_dialog.dart';

class AdicionarRefeicaoScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? refeicao; // Recebe uma refeição para edição

  AdicionarRefeicaoScreen({required this.userId, this.refeicao});

  @override
  _AdicionarRefeicaoScreenState createState() => _AdicionarRefeicaoScreenState();
}

class _AdicionarRefeicaoScreenState extends State<AdicionarRefeicaoScreen> {
  late TextEditingController _descricaoController;
  TimeOfDay? _selectedTime;
  final AuthService _authService = AuthService();
  String? _refeicaoId;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.refeicao?['descricao'] ?? '');
    if (widget.refeicao != null) {
      final hora = (widget.refeicao!['hora'] as Timestamp).toDate();
      _selectedTime = TimeOfDay(hour: hora.hour, minute: hora.minute);
      _refeicaoId = widget.refeicao!['refeicaoId'];
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveRefeicao() async {
    if (_selectedTime != null) {
      final now = DateTime.now();
      final DateTime hora = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      if (_refeicaoId != null) {
        // Atualizar refeição existente
        await _authService.atualizarRefeicao(
          userId: widget.userId,
          refeicaoId: _refeicaoId!,
          hora: hora,
          descricao: _descricaoController.text,
        );
      } else {
        // Adicionar nova refeição
        await _authService.registrarRefeicao(
          userId: widget.userId,
          hora: hora,
          descricao: _descricaoController.text,
        );
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma hora')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: 'Refeição',
        subtitle: 'Adicione as informações abaixo',
        showLogoutButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            SizedBox(height: 10),
            Text(
              _selectedTime != null
                  ? 'Hora selecionada: ${_selectedTime!.format(context)}'
                  : 'Nenhuma hora selecionada',
            ),
            TextButton(
              onPressed: () => _selectTime(context),
              child: Text('Escolher Hora'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){ CustomAlertDialog.show(
                                context: context,
                                title: 'Salvar refeição',
                                content: 'Você tem certeza que deseja salvar esta refeição?',
                                onConfirm: () {
                                  _saveRefeicao();
                                },
                              ); 
                            },
              child: Text(_refeicaoId == null ? 'Adicionar' : 'Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
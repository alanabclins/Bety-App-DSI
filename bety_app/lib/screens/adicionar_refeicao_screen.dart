import 'package:flutter/material.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/utils/alert_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bety_sprint1/models/refeicao.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdicionarRefeicaoScreen extends StatefulWidget {
  final Refeicao? refeicao; // Recebe uma refeição para edição

  AdicionarRefeicaoScreen({this.refeicao});

  @override
  _AdicionarRefeicaoScreenState createState() => _AdicionarRefeicaoScreenState();
}

class _AdicionarRefeicaoScreenState extends State<AdicionarRefeicaoScreen> {
  late TextEditingController _descricaoController;
  TimeOfDay? _selectedTime;
  final RefeicaoService _refeicaoService = RefeicaoService();
  Refeicao? _refeicao;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.refeicao?.descricao ?? '');
    if (widget.refeicao != null) {
      final hora = widget.refeicao!.hora; // Hora como String no formato "HH:mm"
      final timeOfDay = _convertStringToTimeOfDay(hora);
      _selectedTime = timeOfDay;
      _refeicao = widget.refeicao;
    } // Recupera o usuário logado
  }

  // Função para converter uma String "HH:mm" para TimeOfDay
  TimeOfDay _convertStringToTimeOfDay(String horaString) {
    final partes = horaString.split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    return TimeOfDay(hour: horas, minute: minutos);
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
  // Obter o usuário atual da sessão
  User? _currentUser = SessionManager().currentUser;

  if (_selectedTime != null && _currentUser != null) {

    final horaString = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    final refeicaoDocRef = FirebaseFirestore.instance.collection('refeicoes').doc(); // Cria um novo DocumentReference

    if (_refeicao != null) {
      // Atualizar refeição existente
      final refeicaoAtualizada = Refeicao(
        id: _refeicao!.id,
        userRef: _currentUser.uid, // Puxando o uid do usuário da SessionManager
        descricao: _descricaoController.text,
        hora: horaString, // Convertendo DateTime para Timestamp
      );
      await _refeicaoService.atualizarRefeicao(refeicaoAtualizada);
    } else {
      // Adicionar nova refeição
      final novaRefeicao = Refeicao(
        id: refeicaoDocRef, // ID gerado pelo Firestore
        userRef: _currentUser.uid, // Referência do usuário atual
        descricao: _descricaoController.text,
        hora: horaString, // Convertendo DateTime para Timestamp
      );
      await _refeicaoService.adicionarRefeicao(novaRefeicao);
    }

    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, selecione uma hora ou faça login novamente')),
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
              decoration: InputDecoration(
                labelText: 'Descrição',
                filled: true,
                fillColor: const Color.fromARGB(255, 199, 244, 194),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF0BAB7C),
                foregroundColor: Color(0xFFFBFAF3),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.9, // 90% da largura disponível
              child: SizedBox(
                height: 50, // Altura constante
                child: ElevatedButton(
                  onPressed: () {
                    CustomAlertDialog.show(
                      context: context,
                      title: 'Salvar refeição',
                      content: 'Você tem certeza que deseja salvar esta refeição?',
                      onConfirm: _saveRefeicao,
                    );
                  },
                  child: Text(_refeicao == null ? 'Adicionar' : 'Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BAB7C),
                    foregroundColor: Color(0xFFFBFAF3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            if (_refeicao != null) ...[
              SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.9, // 90% da largura disponível
                child: SizedBox(
                  height: 50, // Altura constante
                  child: ElevatedButton(
                    onPressed: () {
                      CustomAlertDialog.show(
                        context: context,
                        title: 'Excluir refeição',
                        content: 'Você tem certeza que deseja excluir esta refeição?',
                        onConfirm: () async {
                          await _refeicaoService.deletarRefeicao(_refeicao!.id);
                          Navigator.pop(context); // Fechar o diálogo ou a tela após a exclusão
                        },
                      );
                    },
                    child: Text('Excluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Cor de fundo vermelha
                      foregroundColor: Color(0xFFFBFAF3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
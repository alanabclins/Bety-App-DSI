import 'package:flutter/material.dart';
import 'package:bety_sprint1/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/utils/alert_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Refeicao {
  final String? id;
  final DateTime hora;
  final String descricao;

  Refeicao({
    this.id,
    required this.hora,
    required this.descricao,
  });

  // Converte um DocumentSnapshot em um objeto Refeicao
  factory Refeicao.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Refeicao(
      id: doc.id,
      hora: (data['hora'] as Timestamp).toDate(),
      descricao: data['descricao'],
    );
  }

  // Converte um objeto Refeicao em um Map<String, dynamic> para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'hora': hora,
      'descricao': descricao,
    };
  }
}

class AdicionarRefeicaoScreen extends StatefulWidget {
  final String userId;
  final Refeicao? refeicao; // Recebe uma refeição para edição

  AdicionarRefeicaoScreen({required this.userId, this.refeicao});

  @override
  _AdicionarRefeicaoScreenState createState() => _AdicionarRefeicaoScreenState();
}

class _AdicionarRefeicaoScreenState extends State<AdicionarRefeicaoScreen> {
  late TextEditingController _descricaoController;
  TimeOfDay? _selectedTime;
  final RefeicaoService _refeicaoService = RefeicaoService();
  Refeicao? _refeicao;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    Future<void> _fetchAndNotify() async {
    final refeicoes = await _refeicaoService.getRefeicoes(widget.userId);
    final now = DateTime.now();

    // Encontrar a próxima refeição
    Refeicao? nextRefeicao = _findNextRefeicao(refeicoes, now);

    if (nextRefeicao != null) {
      // Exibir a notificação com a hora da próxima refeição
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'refeicao_channel_id',
        'Refeição Channel',
        channelDescription: 'Canal para notificações de refeições',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Hora da Refeição',
        'Sua próxima refeição é às ${nextRefeicao.hora.hour}:${nextRefeicao.hora.minute}',
        platformChannelSpecifics,
      );
    }
  }

  Refeicao? _findNextRefeicao(List<Refeicao> refeicoes, DateTime currentTime) {
    DateTime now = DateTime(currentTime.year, currentTime.month, currentTime.day, currentTime.hour, currentTime.minute);

    Refeicao? nextRefeicao;
    Duration shortestDuration = Duration(days: 365); // Um valor grande para começar

    for (var refeicao in refeicoes) {
      DateTime refeicaoDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        refeicao.hora.hour,
        refeicao.hora.minute,
      );

      if (refeicaoDateTime.isAfter(now)) {
        Duration durationToRefeicao = refeicaoDateTime.difference(now);
        if (durationToRefeicao < shortestDuration) {
          shortestDuration = durationToRefeicao;
          nextRefeicao = refeicao;
        }
      }
    }

    return nextRefeicao;
  }
  
  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.refeicao?.descricao ?? '');
    if (widget.refeicao != null) {
      final hora = widget.refeicao!.hora;
      _selectedTime = TimeOfDay(hour: hora.hour, minute: hora.minute);
      _refeicao = widget.refeicao;
    }
    _fetchAndNotify();
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

      if (_refeicao != null) {
        // Atualizar refeição existente
        final refeicaoAtualizada = Refeicao(
          id: _refeicao!.id,
          hora: hora,
          descricao: _descricaoController.text,
        );
        await _refeicaoService.atualizarRefeicao(
          userId: widget.userId,
          refeicao: refeicaoAtualizada,
        );
      } else {
        // Adicionar nova refeição
        final novaRefeicao = Refeicao(
          hora: hora,
          descricao: _descricaoController.text,
        );
        await _refeicaoService.adicionarRefeicao(
          userId: widget.userId,
          refeicao: novaRefeicao,
        );
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma hora')),
      );
    }
  }

  void _deleteRefeicao() async {
    if (_refeicao != null) {
      await _refeicaoService.excluirRefeicao(
        userId: widget.userId,
        refeicaoId: _refeicao!.id!,
      );
      Navigator.pop(context); // Fecha a tela após exclusão
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
                        onConfirm: _deleteRefeicao,
                      );
                    },
                    child: Text('Excluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
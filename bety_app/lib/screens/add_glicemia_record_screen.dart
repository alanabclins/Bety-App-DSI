import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bety_sprint1/utils/custom_app_bar.dart';
import 'package:bety_sprint1/services/session_service.dart';
import 'package:bety_sprint1/models/glicemia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGlicemiaRecordScreen extends StatefulWidget {
  final Glicemia? glicemia; // Recebe uma glicemia para edição

  const AddGlicemiaRecordScreen({this.glicemia, Key? key}) : super(key: key);

  @override
  _AddGlicemiaRecordScreenState createState() => _AddGlicemiaRecordScreenState();
}

class _AddGlicemiaRecordScreenState extends State<AddGlicemiaRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  String _selectedMeasurementType = 'Jejum';
  DateTime _selectedDateTime = DateTime.now();
  Glicemia? _glicemia;

  @override
  void initState() {
    super.initState();
    if (widget.glicemia != null) {
      _glicemia = widget.glicemia;
      _glucoseController.text = _glicemia!.concentracao.toString();
      _selectedDateTime = _glicemia!.dataHora.toDate();
      _selectedMeasurementType = _glicemia!.tipoMedicao;
    }
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
  if (_formKey.currentState!.validate()) {
    final user = SessionManager().currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    final newGlicemia = Glicemia(
      id: _glicemia?.id, // Usa o id existente se estiver editando
      userRef: _glicemia?.userRef ?? user.uid, // Corrigido aqui
      concentracao: double.parse(_glucoseController.text),
      dataHora: Timestamp.fromDate(_selectedDateTime),
      tipoMedicao: _selectedMeasurementType,
    );

    final glicemiaService = GlicemiaService();
    if (_glicemia != null) {
      await glicemiaService.atualizarGlicemia(newGlicemia);
    } else {
      await glicemiaService.adicionarGlicemia(newGlicemia);
    }

    Navigator.of(context).pop();
  }
}

  Future<void> _deleteRecord() async {
    if (_glicemia != null) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza de que deseja excluir este registro?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final glicemiaService = GlicemiaService();
        await glicemiaService.deletarGlicemia(_glicemia!.id);
        Navigator.of(context).pop(); // Retorna para a tela anterior após deletar
      }
    }
  }

  Widget _buildDateTimeField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Data e Hora',
        filled: true,
        fillColor: const Color.fromARGB(255, 199, 244, 194),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Color(0xFF0BAB7C)),
          onPressed: () {
            _selectDateTime(context);
          },
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime),
      ),
    );
  }

  Widget _buildGlucoseField() {
    return TextFormField(
      controller: _glucoseController,
      decoration: InputDecoration(
        labelText: 'Concentração de glicemia (mg/dL)',
        filled: true,
        fillColor: const Color.fromARGB(255, 199, 244, 194),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira a concentração de glicemia';
        }
        final double? glucoseValue = double.tryParse(value);
        if (glucoseValue == null || glucoseValue <= 0) {
          return 'Por favor, insira um valor válido';
        }
        return null;
      },
    );
  }

  Widget _buildMeasurementTypeField() {
    return DropdownButtonFormField<String>(
      value: _selectedMeasurementType,
      decoration: InputDecoration(
        labelText: 'Tipo de medição',
        filled: true,
        fillColor: const Color.fromARGB(255, 199, 244, 194),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: ['Jejum', 'Pós-prandial', 'Aleatória']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMeasurementType = value!;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0BAB7C),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          _glicemia == null ? 'Adicionar' : 'Salvar',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Visibility(
      visible: _glicemia != null, // Só exibe o botão se estiver editando um registro existente
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _deleteRecord,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text(
            'Excluir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mainTitle: _glicemia == null ? 'Adicionar Glicemia' : 'Editar Glicemia',
        subtitle: _glicemia == null
            ? 'Insira os detalhes da medição'
            : 'Edite os detalhes da medição',
        showLogoutButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        color: const Color.fromARGB(255, 251, 250, 243),
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildDateTimeField(),
              const SizedBox(height: 20),
              _buildGlucoseField(),
              const SizedBox(height: 20),
              _buildMeasurementTypeField(),
              const SizedBox(height: 35),
              _buildSubmitButton(),
              const SizedBox(height: 10), // Espaçamento entre os botões
              _buildDeleteButton(), // Adiciona o botão de exclusão
            ],
          ),
        ),
      ),
    );
  }
}

// lib/views/veiculo_edit_page.dart
import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../services/firestore_service.dart';

class VeiculoEditPage extends StatefulWidget {
  final Veiculo veiculo;
  const VeiculoEditPage({required this.veiculo, super.key});

  @override
  State<VeiculoEditPage> createState() => _VeiculoEditPageState();
}

class _VeiculoEditPageState extends State<VeiculoEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _modeloCtrl;
  late final TextEditingController _marcaCtrl;
  late final TextEditingController _placaCtrl;
  late final TextEditingController _anoCtrl;
  late final TextEditingController _combCtrl;
  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    _modeloCtrl = TextEditingController(text: widget.veiculo.modelo);
    _marcaCtrl = TextEditingController(text: widget.veiculo.marca);
    _placaCtrl = TextEditingController(text: widget.veiculo.placa);
    _anoCtrl = TextEditingController(text: widget.veiculo.ano.toString());
    _combCtrl = TextEditingController(text: widget.veiculo.tipoCombustivel);
  }

  @override
  void dispose() {
    _modeloCtrl.dispose();
    _marcaCtrl.dispose();
    _placaCtrl.dispose();
    _anoCtrl.dispose();
    _combCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    widget.veiculo.modelo = _modeloCtrl.text.trim();
    widget.veiculo.marca = _marcaCtrl.text.trim();
    widget.veiculo.placa = _placaCtrl.text.trim();
    widget.veiculo.ano = int.parse(_anoCtrl.text.trim());
    widget.veiculo.tipoCombustivel = _combCtrl.text.trim();

    await _fs.updateVeiculo(widget.veiculo);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veículo atualizado')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Veículo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _modeloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marcaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _anoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _combCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}

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

  final List<String> _tiposCombustivel = [
    'Gasolina',
    'Etanol',
    'Diesel',
    'GNV',
    'Elétrico',
    'Híbrido',
  ];
  String? _combustivelSelecionado;

  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    _modeloCtrl = TextEditingController(text: widget.veiculo.modelo);
    _marcaCtrl = TextEditingController(text: widget.veiculo.marca);
    _placaCtrl = TextEditingController(text: widget.veiculo.placa);
    _anoCtrl = TextEditingController(text: widget.veiculo.ano.toString());

    _combustivelSelecionado = widget.veiculo.tipoCombustivel;
  }

  @override
  void dispose() {
    _modeloCtrl.dispose();
    _marcaCtrl.dispose();
    _placaCtrl.dispose();
    _anoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    widget.veiculo
      ..modelo = _modeloCtrl.text.trim()
      ..marca = _marcaCtrl.text.trim()
      ..placa = _placaCtrl.text.trim()
      ..ano = int.parse(_anoCtrl.text.trim())
      ..tipoCombustivel = _combustivelSelecionado!;

    try {
      await _fs.updateVeiculo(widget.veiculo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veículo atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Veículo'),
        backgroundColor: Colors.deepPurple,
      ),
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
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o modelo' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _marcaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a marca' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _placaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a placa' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _anoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o ano';
                  if (int.tryParse(v) == null) return 'Digite um ano válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _combustivelSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                  border: OutlineInputBorder(),
                ),
                items: _tiposCombustivel.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (novoValor) {
                  setState(() {
                    _combustivelSelecionado = novoValor;
                  });
                },
                validator: (valor) =>
                    valor == null ? 'Selecione o tipo de combustível' : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

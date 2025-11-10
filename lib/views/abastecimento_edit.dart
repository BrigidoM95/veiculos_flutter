import 'package:flutter/material.dart';
import '../models/abastecimento_veiculo.dart';
import '../services/firestore_service.dart';

class AbastecimentoEditPage extends StatefulWidget {
  final Abastecimento abastecimento;
  const AbastecimentoEditPage({required this.abastecimento, super.key});

  @override
  State<AbastecimentoEditPage> createState() => _AbastecimentoEditPageState();
}

class _AbastecimentoEditPageState extends State<AbastecimentoEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _litrosCtrl;
  late final TextEditingController _valorCtrl;
  late final TextEditingController _kmCtrl;
  late final TextEditingController _consumoCtrl;
  late final TextEditingController _obsCtrl;
  late String _tipoCombustivel;

  final FirestoreService _fs = FirestoreService();

  final List<String> _tiposCombustivel = [
    'Gasolina',
    'Etanol',
    'Diesel',
    'GNV',
    'Elétrico',
    'Híbrido',
  ];

  @override
  void initState() {
    super.initState();
    _litrosCtrl = TextEditingController(
      text: widget.abastecimento.quantidadeLitros.toString(),
    );
    _valorCtrl = TextEditingController(
      text: widget.abastecimento.valorPago.toString(),
    );
    _kmCtrl = TextEditingController(
      text: widget.abastecimento.quilometragem.toString(),
    );
    _consumoCtrl = TextEditingController(
      text: widget.abastecimento.consumo.toString(),
    );
    _obsCtrl = TextEditingController(
      text: widget.abastecimento.observacao ?? '',
    );
    _tipoCombustivel = widget.abastecimento.tipoCombustivel;
  }

  @override
  void dispose() {
    _litrosCtrl.dispose();
    _valorCtrl.dispose();
    _kmCtrl.dispose();
    _consumoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      widget.abastecimento
        ..quantidadeLitros = double.parse(_litrosCtrl.text)
        ..valorPago = double.parse(_valorCtrl.text)
        ..quilometragem = double.parse(_kmCtrl.text)
        ..consumo = double.parse(_consumoCtrl.text)
        ..tipoCombustivel = _tipoCombustivel
        ..observacao = _obsCtrl.text.isEmpty ? null : _obsCtrl.text;

      await _fs.updateAbastecimento(widget.abastecimento);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abastecimento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
        title: const Text('Editar Abastecimento'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _tipoCombustivel,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                  border: OutlineInputBorder(),
                ),
                items: _tiposCombustivel
                    .map(
                      (tipo) =>
                          DropdownMenuItem(value: tipo, child: Text(tipo)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _tipoCombustivel = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _litrosCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade (litros)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a quantidade' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valorCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor Pago (R\$)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o valor pago' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kmCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quilometragem',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a quilometragem' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _consumoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Consumo (km/l)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o consumo' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _obsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

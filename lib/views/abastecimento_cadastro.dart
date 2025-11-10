import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prova/main.dart';
import '../models/abastecimento_veiculo.dart';
import '../models/veiculo.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'abastecimento_list.dart';
import 'cadastro_veiculos.dart';
import 'veiculos_list.dart';
import 'login_page.dart';

final userEmail = AuthService().currentUser?.email ?? 'Usuário';

class CadastroAbastecimentoPage extends StatefulWidget {
  const CadastroAbastecimentoPage({super.key});

  @override
  State<CadastroAbastecimentoPage> createState() =>
      _CadastroAbastecimentoPageState();
}

class _CadastroAbastecimentoPageState extends State<CadastroAbastecimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _dataCtrl = TextEditingController();
  final _litrosCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final _consumoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  String? _veiculoSelecionado;
  String? _combustivelSelecionado;

  final List<String> _tiposCombustivel = [
    'Gasolina',
    'Etanol',
    'Diesel',
    'GNV',
    'Elétrico',
    'Híbrido',
  ];

  final FirestoreService _fs = FirestoreService();
  List<Veiculo> _veiculos = [];

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
    _dataCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _carregarVeiculos() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    final veiculos = await _fs.getVeiculos(user.uid);
    setState(() {
      _veiculos = veiculos;
    });
  }

  Future<void> _salvarAbastecimento() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final abastecimento = Abastecimento(
        data: DateTime.now(),
        quantidadeLitros: double.parse(_litrosCtrl.text),
        valorPago: double.parse(_valorCtrl.text),
        quilometragem: double.parse(_kmCtrl.text),
        tipoCombustivel: _combustivelSelecionado!,
        veiculoId: _veiculoSelecionado!,
        consumo: double.parse(_consumoCtrl.text),
        observacao: _obsCtrl.text.isEmpty ? null : _obsCtrl.text,
        ownerUid: AuthService().currentUser!.uid,
      );

      await _fs.addAbastecimento(abastecimento);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abastecimento salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      _litrosCtrl.clear();
      _valorCtrl.clear();
      _kmCtrl.clear();
      _consumoCtrl.clear();
      _obsCtrl.clear();
      setState(() => _combustivelSelecionado = null);

      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AbastecimentoListPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar abastecimento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Abastecimento'),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Menu de Navegação'),
              accountEmail: Text(userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.orange),
              ),
              decoration: const BoxDecoration(color: Colors.orange),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.deepPurple),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthenticatedHome()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
                color: Colors.green,
              ),
              title: const Text('Cadastrar Veículo'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const CadastroVeiculosPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.blueGrey),
              title: const Text('Meus Veículos'),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => VeiculosListPage()));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_gas_station,
                color: Colors.orange,
              ),
              title: const Text('Cadastrar Abastecimento'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const CadastroAbastecimentoPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.blue),
              title: const Text('Meus Abastecimentos'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const AbastecimentoListPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair'),
              onTap: () async {
                await AuthService().signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _veiculoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Veículo',
                  border: OutlineInputBorder(),
                ),
                items: _veiculos.map((v) {
                  return DropdownMenuItem<String>(
                    value: v.id!,
                    child: Text('${v.marca} ${v.modelo} - ${v.placa}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _veiculoSelecionado = v),
                validator: (v) => v == null ? 'Selecione um veículo' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _combustivelSelecionado,
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
                onChanged: (v) => setState(() => _combustivelSelecionado = v),
                validator: (v) =>
                    v == null ? 'Selecione o tipo de combustível' : null,
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
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _salvarAbastecimento,
                icon: const Icon(Icons.local_gas_station, color: Colors.white),
                label: const Text('Salvar Abastecimento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
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

import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'veiculos_list.dart';
import 'login_page.dart';
import '../main.dart';
import 'package:prova/views/abastecimento_cadastro.dart';
import 'package:prova/views/abastecimento_list.dart';

class CadastroVeiculosPage extends StatefulWidget {
  const CadastroVeiculosPage({super.key});

  @override
  State<CadastroVeiculosPage> createState() => _CadastroVeiculosPageState();
}

class _CadastroVeiculosPageState extends State<CadastroVeiculosPage> {
  final _formKey = GlobalKey<FormState>();
  final _modeloCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();
  final _anoCtrl = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Veículo'),
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Menu de Navegação'),
              accountEmail: Text(AuthService().currentUser?.email ?? 'Usuário'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: 16),

                TextFormField(
                  controller: _marcaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a marca' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _placaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a placa' : null,
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final veiculo = Veiculo(
                          modelo: _modeloCtrl.text.trim(),
                          marca: _marcaCtrl.text.trim(),
                          placa: _placaCtrl.text.trim(),
                          ano: int.parse(_anoCtrl.text.trim()),
                          tipoCombustivel: _combustivelSelecionado!,
                          ownerUid: AuthService().currentUser!.uid,
                        );

                        await _fs.addVeiculo(veiculo);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veículo cadastrado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        _modeloCtrl.clear();
                        _marcaCtrl.clear();
                        _placaCtrl.clear();
                        _anoCtrl.clear();
                        setState(() => _combustivelSelecionado = null);

                        await Future.delayed(const Duration(seconds: 2));

                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const VeiculosListPage(),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao salvar: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.directions_car_filled,
                    color: Colors.white,
                  ),
                  label: const Text('Salvar Veículo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
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
      ),
    );
  }
}

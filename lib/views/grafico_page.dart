import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prova/main.dart';
import 'package:prova/views/abastecimento_list.dart';
import 'package:prova/views/login_page.dart';
import '../models/veiculo.dart';
import '../models/abastecimento_veiculo.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'abastecimento_cadastro.dart';
import 'cadastro_veiculos.dart';
import 'veiculos_list.dart';

class GraficoPage extends StatefulWidget {
  const GraficoPage({super.key});

  @override
  State<GraficoPage> createState() => _GraficoPageState();
}

class _GraficoPageState extends State<GraficoPage> {
  final FirestoreService _fs = FirestoreService();
  List<Veiculo> _veiculos = [];
  List<Abastecimento> _abastecimentos = [];

  String? _veiculoSelecionadoId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
  }

  Future<void> _carregarVeiculos() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    final veiculos = await _fs.getVeiculos(user.uid);

    setState(() {
      _veiculos = veiculos;
      _loading = false;
    });
  }

  Future<void> _carregarAbastecimentos(String veiculoId) async {
    final lista = await _fs.getAbastecimentosPorVeiculo(veiculoId);

    setState(() {
      _abastecimentos = lista;
    });
  }

  List<FlSpot> _gerarPontos() {
    if (_abastecimentos.isEmpty) return [];

    _abastecimentos.sort((a, b) => a.data.compareTo(b.data));

    return List.generate(
      _abastecimentos.length,
      (index) => FlSpot(index.toDouble(), _abastecimentos[index].consumo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gráfico de Consumo Litro/Km"),
        backgroundColor: Colors.purple,
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
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.deepPurple),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => AuthenticatedHome()),
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
                  MaterialPageRoute(builder: (_) => AbastecimentoListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart, color: Colors.purple),
              title: const Text("Gráfico de Consumo"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GraficoPage()),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _veiculoSelecionadoId,
                    decoration: const InputDecoration(
                      labelText: "Selecione o Veículo",
                      border: OutlineInputBorder(),
                    ),
                    items: _veiculos
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id!,
                            child: Text("${v.marca} ${v.modelo} - ${v.placa}"),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      setState(() {
                        _veiculoSelecionadoId = id;
                        _abastecimentos = [];
                      });

                      if (id != null) {
                        _carregarAbastecimentos(id);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  if (_veiculoSelecionadoId == null)
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Selecione um veículo para ver o gráfico.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else if (_abastecimentos.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Nenhum abastecimento encontrado.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (_abastecimentos.length - 1).toDouble(),
                          minY: 0,
                          maxY:
                              (_abastecimentos
                                  .map((a) => a.consumo)
                                  .reduce((a, b) => a > b ? a : b)) +
                              5,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 ||
                                      index >= _abastecimentos.length) {
                                    return const Text("");
                                  }
                                  final data = _abastecimentos[index].data;
                                  return Text(
                                    "${data.day}/${data.month}",
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _gerarPontos(),
                              isCurved: true,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.purple, Colors.purple],
                                ),
                              ),
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

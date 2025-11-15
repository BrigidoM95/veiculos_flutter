import 'package:flutter/material.dart';
import 'package:prova/main.dart';
import '../services/firestore_service.dart';
import '../models/veiculo.dart';
import 'veiculo_edit.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'cadastro_veiculos.dart';
import 'package:prova/views/abastecimento_cadastro.dart';
import 'package:prova/views/abastecimento_list.dart';
import 'package:prova/views/grafico_page.dart';

class VeiculosListPage extends StatelessWidget {
  const VeiculosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Veículos'),
        backgroundColor: Colors.blueGrey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Menu de Navegação'),
              accountEmail: Text(AuthService().currentUser?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blueGrey),
              ),
              decoration: const BoxDecoration(color: Colors.blueGrey),
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
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: StreamBuilder<List<Veiculo>>(
        stream: fs.streamVeiculos(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Nenhum veículo cadastrado.'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final v = list[i];
              return ListTile(
                title: Text('${v.modelo} — ${v.marca}'),
                subtitle: Text(
                  'Placa: ${v.placa} • Ano: ${v.ano} • ${v.tipoCombustivel}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VeiculoEditPage(veiculo: v),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('Excluir este veículo?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Não'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Sim'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await fs.deleteVeiculo(v.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veículo excluído')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CadastroVeiculosPage()),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:prova/models/abastecimento_veiculo.dart';
import 'package:prova/services/firestore_service.dart';
import 'package:prova/views/abastecimento_edit.dart';
import 'package:prova/views/abastecimento_cadastro.dart';
import 'package:prova/views/cadastro_veiculos.dart';
import 'package:prova/views/veiculos_list.dart';
import 'package:prova/views/login_page.dart';
import 'package:prova/services/auth_service.dart';
import 'package:prova/main.dart';

class AbastecimentoListPage extends StatefulWidget {
  const AbastecimentoListPage({super.key});

  @override
  State<AbastecimentoListPage> createState() => _AbastecimentoListPageState();
}

class _AbastecimentoListPageState extends State<AbastecimentoListPage> {
  final FirestoreService _fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService().currentUser?.email ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Abastecimentos'),
        backgroundColor: Colors.lightBlueAccent,
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
                child: Icon(Icons.person, size: 40, color: Colors.lightBlue),
              ),
              decoration: const BoxDecoration(color: Colors.lightBlue),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.deepPurple),
              title: const Text('Início'),
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const VeiculosListPage()),
                );
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

      body: StreamBuilder<List<Abastecimento>>(
        stream: _fs.streamAbastecimentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum abastecimento encontrado.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final list = snapshot.data!;
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final abast = list[i];
              return ListTile(
                leading: const Icon(
                  Icons.local_gas_station,
                  color: Colors.orange,
                ),
                title: Text(
                  '${abast.tipoCombustivel} - ${abast.quantidadeLitros.toStringAsFixed(1)} L',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'R\$ ${abast.valorPago.toStringAsFixed(2)} | '
                  '${abast.quilometragem.toStringAsFixed(0)} km',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Editar abastecimento',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AbastecimentoEditPage(abastecimento: abast),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Excluir abastecimento',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('Excluir este abastecimento?'),
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
                          await _fs.deleteAbastecimento(abast.id!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Abastecimento excluído'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
            MaterialPageRoute(
              builder: (_) => const CadastroAbastecimentoPage(),
            ),
          );
        },
      ),
    );
  }
}

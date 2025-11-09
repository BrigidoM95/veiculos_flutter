import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prova/models/veiculo.dart';
import 'package:prova/views/veiculos_list.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'views/login_page.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return MaterialApp(
      title: 'Controle de Veículos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return const LoginPage();
            } else {
              return const AuthenticatedHome();
            }
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class AuthenticatedHome extends StatefulWidget {
  const AuthenticatedHome({super.key});

  @override
  State<AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends State<AuthenticatedHome> {
  final _formKey = GlobalKey<FormState>();
  final _modeloCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();
  final _anoCtrl = TextEditingController();
  final _combustivelCtrl = TextEditingController();
  final FirestoreService _fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService().currentUser?.email ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Veículos')),
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
              title: const Text('Cadastrar Veículo'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthenticatedHome()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Meus Veículos'),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => VeiculosListPage()));
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
                const Text(
                  'Cadastrar Veículo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _modeloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o modelo';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _marcaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a marca';
                    return null;
                  },
                ),
                const SizedBox(height: 16, width: 1),

                TextFormField(
                  controller: _placaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a placa';
                    return null;
                  },
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

                Container(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _combustivelCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Combustível',
                      border: OutlineInputBorder(),
                    ),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Informe o tipo de combustível';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 5),

                ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final veiculo = Veiculo(
                          modelo: _modeloCtrl.text.trim(),
                          marca: _marcaCtrl.text.trim(),
                          placa: _placaCtrl.text.trim(),
                          ano: int.parse(_anoCtrl.text.trim()),
                          tipoCombustivel: _combustivelCtrl.text.trim(),
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
                        _combustivelCtrl.clear();

                        await Future.delayed(
                          const Duration(seconds: 05),
                        ); // pequeno delay opcional
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
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Veículo'),
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
      ),
    );
  }
}

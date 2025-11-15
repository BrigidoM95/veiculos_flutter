import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prova/views/abastecimento_cadastro.dart';
import 'package:prova/views/abastecimento_list.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'views/login_page.dart';
import 'views/cadastro_veiculos.dart';
import 'views/veiculos_list.dart';
import 'views/video_home.dart';

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

class AuthenticatedHome extends StatelessWidget {
  const AuthenticatedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService().currentUser?.email ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem vindo a Oficina Katchow'),
        backgroundColor: Colors.deepPurple,
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
      body: Stack(children: const [VideoBackground(), Center()]),
    );
  }
}

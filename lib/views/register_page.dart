// lib/views/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _loading = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authService.registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Erro ao registrar');
    } catch (e) {
      _showError('Erro desconhecido');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voltar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Exemplo: usuario@gmail.com';
                      if (!v.contains('@')) return 'E-mail inválido, falta @';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'A senha deve ter 6 caracteres ou mais';
                      if (v.length < 6)
                        return 'Senha deve ter ao menos 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar senha',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirme a senha';
                      if (v != _passCtrl.text) return 'As senhas não batem';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          child: const SizedBox(
                            width: double.infinity,
                            child: Center(child: Text('Criar conta')),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

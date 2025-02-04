import 'package:flutter/material.dart';
import 'package:reservas_user/models/user.dart';
import 'package:reservas_user/routes/login.dart';
import 'package:reservas_user/services/database_service.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});
  static String route = '/cadastro';

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> registerHandler() async {
    // Check for empty fields
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Preencha todos os campos'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('As senhas não conferem'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      User newUser = await _databaseService.createUser(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );
      Navigator.of(context).pushReplacementNamed(Login.route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro - AJY Reservas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Crie sua conta no AJY Reservas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 24.0),
                const Text('Nome', style: TextStyle(fontSize: 16)),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Seu nome completo',
                    hintStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Email', style: TextStyle(fontSize: 16)),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'exemplo@id.uff.br',
                    hintStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Senha', style: TextStyle(fontSize: 16)),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '******************',
                    hintStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Confirmar Senha', style: TextStyle(fontSize: 16)),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '******************',
                    hintStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24.0),
                FilledButton(
                  onPressed: registerHandler,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

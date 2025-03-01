import 'package:flutter/material.dart';
import 'package:reservas_user/models/user.dart';
import 'package:reservas_user/routes/alugar/listaPropriedades.dart';

import 'package:reservas_user/services/database_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  static String route = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final DatabaseService databaseService = DatabaseService.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginHandler() async {
    try {
      User usuarioLogado = await databaseService.login(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(ListaPropriedades.route,
          arguments: usuarioLogado);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('AJY Reservas'),
          // backgroundColor: Colors.deepPurple,
          // foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.w400, color: Colors.white),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Faça login para alugar no AJY Reservas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            leadingDistribution:
                                TextLeadingDistribution.proportional,
                            color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        'Email',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'exemplo@id.uff.br',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Senha',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: '******************',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      FilledButton(
                        onPressed: loginHandler,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 8.0),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/cadastro');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          'Clique aqui para se cadastrar',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              ListaPropriedades.route,
                              arguments: null);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          'Continuar sem uma conta',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }
}

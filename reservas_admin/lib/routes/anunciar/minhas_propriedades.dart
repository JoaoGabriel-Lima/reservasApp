import 'package:flutter/material.dart';
import 'package:reservas_admin/models/user.dart';
import 'package:reservas_admin/models/property.dart';
import 'package:reservas_admin/routes/anunciar/cadastrar_propriedade.dart';
import 'package:reservas_admin/services/database_service.dart';

class MinhasPropriedades extends StatefulWidget {
  const MinhasPropriedades({super.key});
  static String route = '/propriedades/minhas_propriedades';

  @override
  State<MinhasPropriedades> createState() => _MinhasPropriedadesState();
}

class _MinhasPropriedadesState extends State<MinhasPropriedades> {
  late User _currentUser;
  final DatabaseService databaseService = DatabaseService.instance;
  List<Property>? _properties;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return;
    }
    _currentUser = args as User;
    _loadProperties(); // load user's properties
  }

  Future<void> _loadProperties() async {
    final props = await databaseService.getProperties(_currentUser.id);
    setState(() {
      _properties = props;
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Propriedades - AJY Reservas'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.w400, color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_currentUser.name),
              accountEmail: Text(_currentUser.email),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Minhas Propriedades'),
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, MinhasPropriedades.route,
                    arguments: _currentUser);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Cadastrar Propriedade'),
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, CadastrarPropriedade.route,
                    arguments: _currentUser);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: _properties == null
              ? const Center(child: CircularProgressIndicator())
              : _properties!.isEmpty
                  ? Center(
                      child: Column(children: [
                        const Text("Minhas Propriedades",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color: Colors.deepPurple)),
                        const SizedBox(height: 4),
                        const Text(
                            "Aqui você pode visualizar e gerenciar suas propriedades.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                color: Colors.black)),
                        const SizedBox(height: 12),
                        FilledButton(
                            onPressed: () => Navigator.pushNamed(
                                context, CadastrarPropriedade.route,
                                arguments: _currentUser),
                            child: const Text(
                              "Adicionar Propriedade",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )),
                        const SizedBox(height: 16),
                        const Text(
                          "Você ainda não possui propriedades cadastradas.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ]),
                    )
                  : Column(children: [
                      const Text("Minhas Propriedades",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: Colors.deepPurple)),
                      SizedBox(height: 4),
                      const Text(
                          "Aqui você pode visualizar e gerenciar suas propriedades.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Colors.black)),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: () => Navigator.pushNamed(
                              context, CadastrarPropriedade.route,
                              arguments: _currentUser),
                          child: const Text(
                            "Adicionar Propriedade",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _properties!.length,
                          itemBuilder: (context, index) {
                            final property = _properties![index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 1,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/propertyDetail',
                                      arguments: property);
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(property
                                                      .thumbnail ==
                                                  "image_path"
                                              ? 'https://cdni.iconscout.com/illustration/premium/thumb/casa-de-praia-6776643-5681243.png?f=webp'
                                              : property.thumbnail),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              property.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 0),
                                            Text(
                                              property.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Preço: R\$${property.price}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color.fromARGB(
                                                    255, 18, 99, 19),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ])),
    );
  }
}

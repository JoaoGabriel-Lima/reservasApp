import 'package:flutter/material.dart';
import 'package:reservas_user/models/property.dart';
import 'package:reservas_user/models/user.dart';
import 'package:reservas_user/services/database_service.dart';

class ListaPropriedades extends StatefulWidget {
  const ListaPropriedades({super.key});
  static String route = '/propriedades/alugar';

  @override
  State<ListaPropriedades> createState() => _ListaPropriedadesState();
}

class _ListaPropriedadesState extends State<ListaPropriedades> {
  late var _currentUser;
  final DatabaseService databaseService = DatabaseService.instance;
  List<Property>? _properties;

  // Controllers de filtros
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _checkinController = TextEditingController();
  final TextEditingController _checkoutController = TextEditingController();
  final TextEditingController _guestController = TextEditingController();

  @override
  void dispose() {
    _ufController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    _checkinController.dispose();
    _checkoutController.dispose();
    _guestController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      // Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      // return;

      // Simulando um usuário logado
      _currentUser = null;
    } else {
      _currentUser = args;
    }
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final props = await databaseService.getProperties();
    setState(() {
      _properties = props;
    });
  }

  Future<void> _searchProperties() async {
    int? amountGuest = _guestController.text.trim().isNotEmpty
        ? int.tryParse(_guestController.text.trim())
        : null;
    final props = await databaseService.searchProperties(
      uf: _ufController.text.trim().isEmpty ? null : _ufController.text.trim(),
      cidade: _cidadeController.text.trim().isEmpty
          ? null
          : _cidadeController.text.trim(),
      bairro: _bairroController.text.trim().isEmpty
          ? null
          : _bairroController.text.trim(),
      amountGuest: amountGuest,
      checkin: _checkinController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_checkinController.text.trim()),
      checkout: _checkoutController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_checkoutController.text.trim()),
    );
    setState(() {
      _properties = props;
    });
  }

  void _clearFilters() {
    _ufController.clear();
    _cidadeController.clear();
    _bairroController.clear();
    _checkinController.clear();
    _checkoutController.clear();
    _guestController.clear();
    _loadProperties();
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Minhas Propriedades - AJY Reservas'),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.w400, color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(1, 24, 26, 33),
              ),
              accountName:
                  Text(_currentUser != null ? _currentUser.name : "Sem conta"),
              accountEmail:
                  Text(_currentUser != null ? _currentUser.email : "-------"),
              currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 40)),
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
        child: Column(
          children: [
            // Filtros
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: _ufController,
                            decoration:
                                const InputDecoration(labelText: 'UF'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: _cidadeController,
                            decoration:
                                const InputDecoration(labelText: 'Cidade'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: _bairroController,
                            decoration:
                                const InputDecoration(labelText: 'Bairro'))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: _checkinController,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Check-in'),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                _checkinController.text =
                                    picked.toIso8601String().substring(0, 10);
                              }
                            })),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: _checkoutController,
                            readOnly: true,
                            decoration:
                                const InputDecoration(labelText: 'Check-out'),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                _checkoutController.text =
                                    picked.toIso8601String().substring(0, 10);
                              }
                            })),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: _guestController,
                            decoration:
                                const InputDecoration(labelText: 'Pessoas'))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _searchProperties,
                        child: const Text('Buscar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearFilters,
                        child: const Text('Limpar Filtros'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Listagem de propriedades
            _properties == null
                ? const Center(child: CircularProgressIndicator())
                : _properties!.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              Text("Propriedades para Alugar",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                      color: Colors.blue)),
                              SizedBox(height: 4),
                              Text(
                                "Nenhuma propriedade encontrada com os filtros aplicados.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _properties!.length,
                          itemBuilder: (context, index) {
                            final property = _properties![index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 1,
                              child: InkWell(
                                onTap: () {
                                  if (_currentUser == null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Atenção"),
                                        content: const Text(
                                            "Você precisa fazer login para ver os detalhes da propriedade."),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/propriedades/detalhes', // página detalhes da propriedade
                                      arguments: {
                                        'propertyId': property.id,
                                        'userId': _currentUser.id,
                                      },
                                    );
                                  }
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 0),
                                            Text(
                                              property.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                // add rating
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                        (property.rating ?? 0.0)
                                                            .toString())
                                                  ],
                                                ),
                                                const SizedBox(width: 16),
                                                Text(
                                                  "Preço: R\$${property.price}",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color.fromARGB(
                                                          255, 81, 184, 82)),
                                                ),
                                              ],
                                            )
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
          ],
        ),
      ),
    );
  }
}

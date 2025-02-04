import 'package:flutter/material.dart';
import 'package:reservas_admin/models/address.dart';
import 'package:reservas_admin/models/property.dart';
import 'package:reservas_admin/models/user.dart';
import 'package:reservas_admin/services/database_service.dart';

class EditarPropriedade extends StatefulWidget {
  const EditarPropriedade({super.key});
  static String route = '/propriedades/editar_propriedade';

  @override
  State<EditarPropriedade> createState() => _EditarPropriedadeState();
}

class _EditarPropriedadeState extends State<EditarPropriedade> {
  final DatabaseService databaseService = DatabaseService.instance;

  late int propertyId;
  late User currentUser;
  bool _isLoading = true;

  // Controladores para endereço
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _localidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _estadoController = TextEditingController();
  // Controladores para propriedade
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestController = TextEditingController();
  final _thumbnailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Espera argumentos com o id da propriedade e o usuário atual
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null ||
        !args.containsKey('propertyId') ||
        !args.containsKey('user')) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    propertyId = args['propertyId'] as int;
    currentUser = args['user'] as User;
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      // Carrega a propriedade e o endereço associado
      Property property = await databaseService.getPropertyById(propertyId);
      Address address = await databaseService.getAddress(property.address_id);
      // Preenche os controladores com os dados existentes
      setState(() {
        _cepController.text = address.cep;
        _logradouroController.text = address.logradouro;
        _bairroController.text = address.bairro;
        _localidadeController.text = address.localidade;
        _ufController.text = address.uf;
        _estadoController.text = address.estado;
        _titleController.text = property.title;
        _descriptionController.text = property.description;
        _numberController.text = property.number.toString();
        _complementController.text = property.complement;
        _priceController.text = property.price.toString();
        _maxGuestController.text = property.max_guest.toString();
        _thumbnailController.text = property.thumbnail;
        _isLoading = false;
      });
    } catch (e) {
      // Tratar erro, se necessário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await databaseService.editProperty(
        propertyId: propertyId,
        cep: _cepController.text,
        logradouro: _logradouroController.text,
        bairro: _bairroController.text,
        localidade: _localidadeController.text,
        uf: _ufController.text,
        estado: _estadoController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        number: int.parse(_numberController.text),
        complement: _complementController.text,
        price: double.parse(_priceController.text),
        max_guest: int.parse(_maxGuestController.text),
        thumbnail: _thumbnailController.text,
      );
      Navigator.pop(context); // ou redirecionar conforme fluxo desejado
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao editar propriedade: $e')),
      );
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _localidadeController.dispose();
    _ufController.dispose();
    _estadoController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _priceController.dispose();
    _maxGuestController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Propriedade - AJY Reservas'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Dados de Endereço
                    TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(labelText: 'CEP'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o CEP'
                          : null,
                    ),
                    TextFormField(
                      controller: _logradouroController,
                      decoration:
                          const InputDecoration(labelText: 'Logradouro'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o logradouro'
                          : null,
                    ),
                    TextFormField(
                      controller: _bairroController,
                      decoration: const InputDecoration(labelText: 'Bairro'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o bairro'
                          : null,
                    ),
                    TextFormField(
                      controller: _localidadeController,
                      decoration:
                          const InputDecoration(labelText: 'Localidade'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe a localidade'
                          : null,
                    ),
                    TextFormField(
                      controller: _ufController,
                      decoration: const InputDecoration(labelText: 'UF'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe a UF'
                          : null,
                    ),
                    TextFormField(
                      controller: _estadoController,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o estado'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    // Dados da Propriedade
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o título'
                          : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe a descrição'
                          : null,
                    ),
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(labelText: 'Número'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o número'
                          : null,
                    ),
                    TextFormField(
                      controller: _complementController,
                      decoration:
                          const InputDecoration(labelText: 'Complemento'),
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o preço'
                          : null,
                    ),
                    TextFormField(
                      controller: _maxGuestController,
                      decoration: const InputDecoration(
                          labelText: 'Máximo de Hóspedes'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o máximo de hóspedes'
                          : null,
                    ),
                    TextFormField(
                      controller: _thumbnailController,
                      decoration: const InputDecoration(labelText: 'Thumbnail'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe a thumbnail'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Salvar Alterações'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remover Propriedade'),
                            content: const Text(
                                'Tem certeza que deseja remover esta propriedade?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Remover'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await databaseService.removeProperty(propertyId);
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Erro ao remover propriedade: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(color: Colors.white)),
                      child: const Text('Remover Propriedade'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

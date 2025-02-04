import 'package:flutter/material.dart';
import 'package:reservas_user/models/property.dart';
import 'package:reservas_user/services/database_service.dart';

class DetalhesPropriedade extends StatefulWidget {
  const DetalhesPropriedade({super.key});
  static String route = '/propriedades/detalhes';

  @override
  State<DetalhesPropriedade> createState() => _DetalhesPropriedadeState();
}

class _DetalhesPropriedadeState extends State<DetalhesPropriedade> {
  final DatabaseService databaseService = DatabaseService.instance;
  Property? property;
  List<String>? images;
  int? userId;
  int? propertyId;

  // Reservation controllers
  final TextEditingController _checkinController = TextEditingController();
  final TextEditingController _checkoutController = TextEditingController();
  final TextEditingController _guestController = TextEditingController();

  bool _loadingReservation = false;

  @override
  void initState() {
    super.initState();
    // delay to load route arguments
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        userId = args['userId'] as int?;
        propertyId = args['propertyId'] as int?;
        _loadData();
      } else {
        Navigator.of(context).pop();
        return;
      }
    });
  }

  Future<void> _loadData() async {
    if (propertyId != null) {
      final fetchedProperty =
          await databaseService.getPropertyById(propertyId!);
      final fetchedImages = await databaseService.getImages(propertyId!);
      setState(() {
        property = fetchedProperty;
        images = fetchedImages;
      });
    }
  }

  Future<void> _makeReservation() async {
    if (userId == null || propertyId == null) return;
    final checkin = DateTime.tryParse(_checkinController.text);
    final checkout = DateTime.tryParse(_checkoutController.text);
    final amountGuest = int.tryParse(_guestController.text.trim());
    if (checkin == null || checkout == null || amountGuest == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Preencha todos os campos corretamente.")));
      return;
    }
    if (amountGuest > property!.max_guest) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Número de hóspedes excede o limite da propriedade.")));
      return;
    }

    if (checkout.isBefore(checkin)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Data de check-out deve ser após a data de check-in.")));
      return;
    }

    setState(() {
      _loadingReservation = true;
    });
    try {
      await databaseService.bookProperty(
          userId: userId!,
          propertyId: propertyId!,
          checkin: checkin,
          checkout: checkout,
          amountGuest: amountGuest);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva efetuada com sucesso.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao reservar: $e")));
    } finally {
      setState(() {
        _loadingReservation = false;
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().substring(0, 10);
    }
  }

  void _showReservationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Compute final value if possible
            DateTime? checkin = DateTime.tryParse(_checkinController.text);
            DateTime? checkout = DateTime.tryParse(_checkoutController.text);
            double? finalValue;
            if (checkin != null &&
                checkout != null &&
                checkout.isAfter(checkin)) {
              int nights = checkout.difference(checkin).inDays;
              if (nights < 1) nights = 1;
              finalValue = nights * (property?.price ?? 0);
            }
            return AlertDialog(
              title: const Text("Faça sua reserva"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _checkinController,
                      readOnly: true,
                      decoration: const InputDecoration(
                          labelText: 'Check-in (AAAA-MM-DD)'),
                      onTap: () async {
                        await _selectDate(_checkinController);
                        setStateDialog(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _checkoutController,
                      readOnly: true,
                      decoration: const InputDecoration(
                          labelText: 'Check-out (AAAA-MM-DD)'),
                      onTap: () async {
                        await _selectDate(_checkoutController);
                        setStateDialog(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _guestController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Pessoas'),
                    ),
                    const SizedBox(height: 16),
                    if (finalValue != null)
                      Text(
                        "Valor Final: R\$${finalValue.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: _loadingReservation
                      ? null
                      : () async {
                          await _makeReservation();
                          Navigator.of(context).pop();
                        },
                  child: _loadingReservation
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Reservar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _checkinController.dispose();
    _checkoutController.dispose();
    _guestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes da Propriedade")),
      body: property == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Info Card with details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Image.network(
                            property!.thumbnail == "image_path"
                                ? 'https://cdni.iconscout.com/illustration/premium/thumb/casa-de-praia-6776643-5681243.png?f=webp'
                                : property!.thumbnail,
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(property!.title,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text("${property!.rating}")
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text("Número: ${property!.number}"),
                                Text("Complemento: ${property!.complement}"),
                                Text(
                                    "Máximo de hóspedes: ${property!.max_guest}"),
                                Text("Preço: R\$${property!.price}"),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(property!.description),
                  const SizedBox(height: 16),
                  // Images slider
                  SizedBox(
                    height: 120,
                    child: images == null || images!.isEmpty
                        ? const Center(child: Text("Sem imagens"))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images!.length,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Image.network(
                                images![index],
                                width: 150,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ),
                  const Divider(height: 32),
                  // Replace inline reservation form with a button.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showReservationDialog,
                      child: const Text("Fazer Reserva"),
                    ),
                  ),
                  // ...other property details if any...
                ],
              ),
            ),
    );
  }
}

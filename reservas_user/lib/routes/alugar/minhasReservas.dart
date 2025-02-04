import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:reservas_user/models/booking.dart';
import 'package:reservas_user/models/property.dart';
import 'package:reservas_user/services/database_service.dart';
import 'package:intl/intl.dart';

class MinhasReservas extends StatefulWidget {
  const MinhasReservas({super.key});
  static String route = '/minhasreservas';

  @override
  State<MinhasReservas> createState() => _MinhasReservasState();
}

class _MinhasReservasState extends State<MinhasReservas> {
  final DatabaseService _dbService = DatabaseService.instance;
  List<Booking> _bookings = [];
  Map<int, Property> _bookingProperties = {};
  int? userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Recebe o userId dos argumentos
    Future.microtask(() async {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      userId = args?['userId'] as int?;
      if (userId == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      await _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    final bookings = await _dbService.getBookings(userId!);
    Map<int, Property> propMap = {};
    for (var booking in bookings) {
      Property property = await _dbService.getPropertyById(booking.property_id);
      propMap[booking.id] = property;
    }
    setState(() {
      _bookings = bookings;
      _bookingProperties = propMap;
      _loading = false;
    });
  }

  Future<void> _cancelBooking(Booking booking) async {
    bool confirm = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancelar Reserva"),
          content: const Text("Tem certeza que deseja cancelar esta reserva?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Não"),
            ),
            ElevatedButton(
              onPressed: () {
                confirm = true;
                Navigator.of(context).pop();
              },
              child: const Text("Sim"),
            )
          ],
        );
      },
    );
    if (confirm) {
      await _dbService.removeBooking(bookingId: booking.id);
      setState(() {
        _bookings.remove(booking);
        _bookingProperties.remove(booking.id);
      });
    }
  }

  Future<void> _reviewBooking(Booking booking) async {
    final TextEditingController _ratingController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Avalie sua estadia"),
          content: TextField(
            controller: _ratingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nota (0 a 5)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                double? rating = double.tryParse(_ratingController.text.trim());
                if (rating == null || rating < 0 || rating > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nota inválida")));
                  return;
                }
                await _dbService.rateBooking(
                    bookingId: booking.id, rating: rating);
                Navigator.of(context).pop();
              },
              child: const Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  String _fancyDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    return DateFormat.yMMMMEEEEd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Reservas")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text("Sem reservas"))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    final property = _bookingProperties[booking.id];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Exibe data da reserva (check-in e check-out)
                            Text(
                              "Reserva: ${_fancyDate(booking.checkin_date)} - ${_fancyDate(booking.checkout_date)}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Thumbnail da propriedade
                                property != null
                                    ? Image.network(
                                        property.thumbnail == "image_path"
                                            ? 'https://cdni.iconscout.com/illustration/premium/thumb/casa-de-praia-6776643-5681243.png?f=webp'
                                            : property.thumbnail,
                                        width: 100,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 80,
                                        color: Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Título da propriedade
                                      Text(
                                        property?.title ??
                                            "Propriedade desconhecida",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(height: 0),
                                      // Endereço da propriedade
                                      Text(
                                        property?.description ?? "",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),

                                      // Valor total da reserva
                                      Text(
                                        "Valor Total: R\$ ${booking.total_price.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Botão para cancelar reserva
                                TextButton(
                                  onPressed: () => _cancelBooking(booking),
                                  child: const Text("Cancelar Reserva"),
                                ),
                                const SizedBox(width: 8),
                                // Botão para avaliar estadia
                                ElevatedButton(
                                  onPressed: () => _reviewBooking(booking),
                                  child: const Text("Avaliar"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

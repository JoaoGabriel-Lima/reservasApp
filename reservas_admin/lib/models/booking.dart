class Booking {
  final int id;
  final int user_id;
  final int property_id;
  final String checkin_date;
  final String checkout_date;
  final int total_days;
  final double total_price;
  final int amount_guests;
  final double rating;

  Booking(
      {required this.id,
      required this.user_id,
      required this.property_id,
      required this.checkin_date,
      required this.checkout_date,
      required this.total_days,
      required this.total_price,
      required this.amount_guests,
      required this.rating});
}

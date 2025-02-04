class Property {
  final int id;
  final int user_id;
  final int address_id;
  final String title;
  final String description;
  final int number;
  final String complement;
  final double price;
  final int max_guest;
  final String thumbnail;
  double rating = 0.0;

  Property(
      {required this.id,
      required this.user_id,
      required this.address_id,
      required this.title,
      required this.description,
      required this.number,
      required this.complement,
      required this.price,
      required this.max_guest,
      required this.thumbnail,
      this.rating = 0.0});
}

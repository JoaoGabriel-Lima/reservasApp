import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reservas_user/models/address.dart';
import 'package:reservas_user/models/property.dart';
import 'package:reservas_user/models/user.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    String databasePath = '';
    if (kIsWeb) {
      databasePath = 'reserva_db.db';
    } else {
      final databaseDirPath = await getApplicationDocumentsDirectory();
      databasePath = join(databaseDirPath.path, 'reserva_bd.db');
    }

    print(databasePath);
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        var batch = db.batch();
        batch.execute('''
          CREATE TABLE user(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              email TEXT NOT NULL,
              password TEXT NOT NULL
          )
        ''');
        batch.execute('''
          INSERT INTO user(name, email, password) VALUES('Teste 1', 'teste1@teste', '123456')
        ''');
        batch.execute('''
          INSERT INTO user(name, email, password) VALUES('Teste 2', 'teste2@teste', '123456')
        ''');
        batch.execute('''
          INSERT INTO user(name, email, password) VALUES('Teste 3', 'teste3@teste', '123456')
        ''');
        batch.execute('''
          INSERT INTO user(name, email, password) VALUES('Teste 4', 'teste4@teste', '123456')
        ''');
        batch.execute('''
          INSERT INTO user(name, email, password) VALUES('Teste 5', 'teste5@teste', '123456')
        ''');
        batch.execute('''
          CREATE TABLE address(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cep TEXT NOT NULL UNIQUE,
              logradouro TEXT NOT NULL,
              bairro TEXT NOT NULL,
              localidade TEXT NOT NULL,
              uf TEXT NOT NULL,
              estado TEXT NOT NULL
          )
        ''');
        batch.execute('''
          INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES('01001000', 'Praça da Sé', 'Sé', 'São Paulo', 'SP', 'São Paulo')
        ''');
        batch.execute('''
          INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES('24210346', 'Avenida General Milton Tavares de Souza', 'Gragoatá', 'Niterói', 'RJ', 'Rio de Janeiro')
        ''');
        batch.execute('''
          CREATE TABLE property(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              address_id INTEGER NOT NULL,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              number INTEGER NOT NULL,
              complement TEXT,
              price REAL NOT NULL,
              max_guest INTEGER NOT NULL,
              thumbnail TEXT NOT NULL,
              FOREIGN KEY(user_id) REFERENCES user(id),
              FOREIGN KEY(address_id) REFERENCES address(id)
          )
        ''');
        batch.execute('''
          INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 1, 'Apartamento Quarto Privativo', 'Apartamento perto do Centro com 2 quartos, cozinha e lavanderia.', 100, 'Apto 305', 120.0, 2, 'image_path')
        ''');
        batch.execute('''
          INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 1, 'Hotel Ibis', 'Quarto Básico com cama casal.', 200, NULL, 220.0, 2, 'image_path')
        ''');
        batch.execute('''
          INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 2, 'Pousada X', 'Quarto Básico com cama casal e cama de solteiro.', 300, NULL, 320.0, 3, 'image_path')
        ''');
        batch.execute('''
          INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 2, 'Chalé perto de praia', 'Quarto com cama casal.', 400, NULL, 420.0, 2, 'image_path')
        ''');
        batch.execute('''
          CREATE TABLE images(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              property_id INTEGER NOT NULL,
              path TEXT NOT NULL,
              FOREIGN KEY(property_id) REFERENCES property(id)
          )
        ''');
        batch.execute('''
          INSERT INTO images(property_id, path) VALUES(1, 'image_path_1')
        ''');
        batch.execute('''
          INSERT INTO images(property_id, path) VALUES(1, 'image_path_2')
        ''');
        batch.execute('''
          INSERT INTO images(property_id, path) VALUES(1, 'image_path_3')
        ''');
        batch.execute('''
          INSERT INTO images(property_id, path) VALUES(2, 'image_path_1')
        ''');
        batch.execute('''
          INSERT INTO images(property_id, path) VALUES(2, 'image_path_2')
        ''');
        batch.execute('''
          INSERT INTO images(property_id, path) VALUES(2, 'image_path_3')
        ''');
        batch.execute('''
          CREATE TABLE booking(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              property_id INTEGER NOT NULL,
              checkin_date TEXT NOT NULL,
              checkout_date TEXT NOT NULL,
              total_days INTEGER NOT NULL,
              total_price REAL NOT NULL,
              amount_guest INTEGER NOT NULL,
              rating REAL,
              FOREIGN KEY(user_id) REFERENCES user(id),
              FOREIGN KEY(property_id) REFERENCES property(id)
          )
        ''');
        batch.execute('''
          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(4, 1, '2025-02-01', '2025-02-03', 2, 240.0, 2, NULL)
        ''');
        batch.execute('''
          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(4, 2, '2025-04-01', '2025-04-03', 2, 480.0, 1, NULL)
        ''');
        batch.execute('''
          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(3, 3, '2025-05-09', '2025-05-15', 6, 1920.0, 2, NULL)
        ''');
        batch.execute('''
          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(5, 3, '2025-09-09', '2025-09-15', 6, 1920.0, 2, NULL)
        ''');
        batch.execute('''
          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(1, 4, '2025-09-09', '2025-09-15', 6, 2520.0, 2, NULL)
        ''');
        await batch.commit(noResult: true);
      },
    );
    return database;
  }

  // Criar usuário
  Future<User> createUser(String name, String email, String password) async {
    final db = await database;
    final id = await db.rawInsert(
        'INSERT INTO user(name, email, password) VALUES(?, ?, ?)',
        [name, email, password]);

    final user = User(id: id, name: name, email: email, password: password);
    return user;
  }

  // login
  Future<User> login(String email, String password) async {
    final db = await database;

    final user = await db.rawQuery(
        'SELECT * FROM user WHERE email = ? AND password = ?',
        [email, password]);

    print(email);
    print(password);
    print(user);
    if (user.isNotEmpty) {
      return User(
        id: user[0]['id'] as int,
        name: user[0]['name'] as String,
        email: user[0]['email'] as String,
        password: "*********",
      );
    }
    throw Exception('Usuário não encontrado');
  }

  // get rating average of a property by id
  Future<double> getRating(int property_id) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT AVG(rating) as rating FROM booking WHERE property_id = ?',
        [property_id]);

    if (result[0]['rating'] == null) return 0.0;
    return result[0]['rating'] as double;
  }

  Future<List<Property>> getProperties() async {
    final db = await database;
    final properties = await db.rawQuery('SELECT * FROM property');

    final List<Property> propertiesList = [];
    for (var property in properties) {
      final double rating = await getRating(property['id'] as int);
      propertiesList.add(Property(
          id: property['id'] as int,
          user_id: property['user_id'] as int,
          address_id: property['address_id'] as int,
          title: property['title'] as String,
          description: property['description'] as String,
          number: property['number'] as int,
          complement: property['complement'] != null
              ? property['complement'] as String
              : "",
          price: property['price'] as double,
          max_guest: property['max_guest'] as int,
          thumbnail: property['thumbnail'] as String,
          rating: rating));
    }
    return propertiesList;
  }

  // Obter todas as imagens de uma propriedade
  Future<List<String>> getImages(int property_id) async {
    final db = await database;
    final images = await db
        .rawQuery('SELECT * FROM images WHERE property_id = ?', [property_id]);

    final List<String> imagesList = [];
    for (var image in images) {
      imagesList.add(image['path'] as String);
    }
    return imagesList;
  }

  // get address by id
  Future<Address> getAddress(int address_id) async {
    final db = await database;
    final address =
        await db.rawQuery('SELECT * FROM address WHERE id = ?', [address_id]);

    if (address.isNotEmpty) {
      return Address(
          id: address[0]['id'] as int,
          cep: address[0]['cep'] as String,
          logradouro: address[0]['logradouro'] as String,
          bairro: address[0]['bairro'] as String,
          localidade: address[0]['localidade'] as String,
          uf: address[0]['uf'] as String,
          estado: address[0]['estado'] as String);
    }
    throw Exception('Endereço não encontrado');
  }

  // Obter propriedade por id
  Future<Property> getPropertyById(int propertyId) async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT * FROM property WHERE id = ?', [propertyId]);
    if (result.isEmpty) throw Exception('Propriedade não encontrada');
    final property = result.first;
    final double rating = await getRating(property['id'] as int);
    return Property(
      id: property['id'] as int,
      user_id: property['user_id'] as int,
      address_id: property['address_id'] as int,
      title: property['title'] as String,
      description: property['description'] as String,
      number: property['number'] as int,
      complement: property['complement'] != null
          ? property['complement'] as String
          : "",
      price: property['price'] as double,
      max_guest: property['max_guest'] as int,
      thumbnail: property['thumbnail'] as String,
      rating: rating,
    );
  }

  Future<int> bookProperty({
    required int userId,
    required int propertyId,
    required DateTime checkin,
    required DateTime checkout,
    required int amountGuest,
  }) async {
    final db = await database;
    final property = await getPropertyById(propertyId);
    final totalDays = checkout.difference(checkin).inDays;
    final totalPrice = property.price * totalDays;
    final checkinStr = checkin.toIso8601String();
    final checkoutStr = checkout.toIso8601String();

    // Check for overlapping bookings
    final overlappingBookings = await db.rawQuery('''
      SELECT * FROM booking 
      WHERE property_id = ? 
        AND checkin_date < ? 
        AND checkout_date > ?
      ''', [propertyId, checkoutStr, checkinStr]);
    if (overlappingBookings.isNotEmpty) {
      throw Exception('Esta propriedade já está alugada');
    }

    final bookingId = await db.rawInsert('''
      INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating)
      VALUES(?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      userId,
      propertyId,
      checkinStr,
      checkoutStr,
      totalDays,
      totalPrice,
      amountGuest,
      null
    ]);

    return bookingId;
  }

  Future<int> rateBooking(
      {required int bookingId, required double rating}) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE booking SET rating = ? WHERE id = ?',
      [rating, bookingId],
    );
  }

  Future<int> removeBooking({required int bookingId}) async {
    final db = await database;
    return await db.rawDelete(
      'DELETE FROM booking WHERE id = ?',
      [bookingId],
    );
  }

  Future<List<Property>> searchProperties({
    String? uf,
    String? cidade,
    String? bairro,
    DateTime? checkin,
    DateTime? checkout,
    int? amountGuest,
  }) async {
    final db = await database;
    List<String> conditions = [];
    List<dynamic> args = [];
    if (uf != null && uf.isNotEmpty) {
      conditions.add("address.uf = ?");
      args.add(uf);
    }
    if (cidade != null && cidade.isNotEmpty) {
      conditions.add("address.localidade = ?");
      args.add(cidade);
    }
    if (bairro != null && bairro.isNotEmpty) {
      conditions.add("address.bairro = ?");
      args.add(bairro);
    }
    if (amountGuest != null) {
      conditions.add("property.max_guest >= ?");
      args.add(amountGuest);
    }

    // Compute a one-day interval if only one date is provided.
    DateTime? desiredCheckin;
    DateTime? desiredCheckout;
    if (checkin != null && checkout != null) {
      desiredCheckin = checkin;
      desiredCheckout = checkout;
    } else if (checkin != null) {
      desiredCheckin = checkin;
      desiredCheckout = checkin.add(const Duration(days: 1));
    } else if (checkout != null) {
      desiredCheckin = checkout;
      desiredCheckout = checkout.add(const Duration(days: 1));
    }

    String whereClause =
        conditions.isNotEmpty ? "WHERE " + conditions.join(" AND ") : "";
    // Add exclusion clause for booking interval if at least one date is provided.
    if (desiredCheckin != null && desiredCheckout != null) {
      final bookingCondition =
          "property.id NOT IN (SELECT property_id FROM booking WHERE (checkin_date < ? AND checkout_date > ?))";
      if (whereClause.isEmpty) {
        whereClause = "WHERE " + bookingCondition;
      } else {
        whereClause = "$whereClause AND $bookingCondition";
      }
      args.add(desiredCheckout.toIso8601String());
      args.add(desiredCheckin.toIso8601String());
    }
    final results = await db.rawQuery('''
      SELECT property.*
      FROM property
      JOIN address ON property.address_id = address.id
      $whereClause
    ''', args);
    List<Property> propertiesList = [];
    for (var property in results) {
      final double rating = await getRating(property['id'] as int);
      propertiesList.add(Property(
          id: property['id'] as int,
          user_id: property['user_id'] as int,
          address_id: property['address_id'] as int,
          title: property['title'] as String,
          description: property['description'] as String,
          number: property['number'] as int,
          complement: property['complement'] != null
              ? property['complement'] as String
              : "",
          price: property['price'] as double,
          max_guest: property['max_guest'] as int,
          thumbnail: property['thumbnail'] as String,
          rating: rating));
    }
    return propertiesList;
  }
}

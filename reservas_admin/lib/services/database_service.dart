import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:reservas_admin/models/address.dart';
import 'package:reservas_admin/models/property.dart';
import 'package:reservas_admin/models/user.dart';
import 'package:path_provider/path_provider.dart';
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
      databasePath = join(databaseDirPath.path, '', 'reserva_db.db');
    }

    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE user(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name VARCHAR NOT NULL,
              email VARCHAR NOT NULL,
              password VARCHAR NOT NULL
          );

          INSERT INTO user(name, email, password) VALUES('Teste 1', 'teste1@teste', '123456');
          INSERT INTO user(name, email, password) VALUES('Teste 2', 'teste2@teste', '123456');
          INSERT INTO user(name, email, password) VALUES('Teste 3', 'teste3@teste', '123456');
          INSERT INTO user(name, email, password) VALUES('Teste 4', 'teste4@teste', '123456');
          INSERT INTO user(name, email, password) VALUES('Teste 5', 'teste5@teste', '123456');

          CREATE TABLE address(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cep VARCHAR NOT NULL UNIQUE,
              logradouro VARCHAR NOT NULL,
              bairro VARCHAR NOT NULL,
              localidade VARCHAR NOT NULL,
              uf VARCHAR NOT NULL,
              estado VARCHAR NOT NULL
          );

          INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES('01001000', 'Praça da Sé', 'Sé', 'São Paulo', 'SP', 'São Paulo');
          INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES('24210346', 'Avenida General Milton Tavares de Souza', 'Gragoatá', 'Niterói', 'RJ', 'Rio de Janeiro');

          CREATE TABLE property(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
            address_id INTEGER NOT NULL,
              title VARCHAR NOT NULL,
              description VARCHAR NOT NULL,
            number INTEGER NOT NULL,
              complement VARCHAR,
              price REAL NOT NULL,
              max_guest INTEGER NOT NULL,
              thumbnail VARCHAR NOT NULL,
              FOREIGN KEY(user_id) REFERENCES user(id),
            FOREIGN KEY(address_id) REFERENCES address(id)
          );

          INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 1, 'Apartamento Quarto Privativo', 'Apartamento perto do Centro com 2 quartos, cozinha e lavanderia.', 100, 'Apto 305', 120.0, 2, 'image_path');
          INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 1, 'Hotel Ibis', 'Quarto Básico com cama casal.', 200, NULL, 220.0, 2, 'image_path');
          INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 2, 'Pousada X', 'Quarto Básico com cama casal e cama de solteiro.', 300, NULL, 320.0, 3, 'image_path');
          INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(1, 2, 'Chalé perto de praia', 'Quarto com cama casal.', 400, NULL, 420.0, 2, 'image_path');


          CREATE TABLE images(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              property_id INTEGER NOT NULL,
              path VARCHAR NOT NULL,    
            FOREIGN KEY(property_id) REFERENCES property(id)
          );

          INSERT INTO images(property_id, path) VALUES(1, 'image_path_1' );
          INSERT INTO images(property_id, path) VALUES(1, 'image_path_2' );
          INSERT INTO images(property_id, path) VALUES(1, 'image_path_3' );
          INSERT INTO images(property_id, path) VALUES(2, 'image_path_1' );
          INSERT INTO images(property_id, path) VALUES(2, 'image_path_2' );
          INSERT INTO images(property_id, path) VALUES(2, 'image_path_3' );

          CREATE TABLE booking(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            property_id INTEGER NOT NULL,
              checkin_date VARCHAR NOT NULL,
            checkout_date VARCHAR NOT NULL,
              total_days INTEGER NOT NULL,
              total_price REAL NOT NULL,
              amount_guest INTEGER NOT NULL,
              rating REAL,
            FOREIGN KEY(user_id) REFERENCES user(id),
            FOREIGN KEY(property_id) REFERENCES property(id)
          );

          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(4, 1, '2025-02-01', '2025-02-03', 2, 240.0, 2, NULL);

          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(4, 2, '2025-04-01', '2025-04-03', 2, 480.0, 1, NULL);
          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(3, 3, '2025-05-09', '2025-05-15', 6, 1920.0, 2, NULL);
          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(5, 3, '2025-09-09', '2025-09-15', 6, 1920.0, 2, NULL);
          INSERT INTO booking(user_id, property_id, checkin_date, checkout_date, total_days, total_price, amount_guest, rating) VALUES(1, 4, '2025-09-09', '2025-09-15', 6, 2520.0, 2, NULL);


          select user.name, property.title, booking.checkin_date, booking.checkout_date, booking.total_price from booking left join user on booking.user_id = user.id left join property on property.id = booking.property_id;

          select property.title, address.logradouro, address.bairro, address.localidade, address.uf, property.number, property.complement, property.price from property left join address on address.id = property.address_id;

          select property.title, images.path from property left join images on property.id = images.property_id;

          select id, checkin_date, strftime('%d', checkin_date) as 'Day' from booking where strftime('%m', checkin_date) = '04';
        ''');
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

  // Adicionar propriedade
  Future<Property> addProperty(
      int user_id,
      String cep,
      String logradouro,
      String bairro,
      String localidade,
      String uf,
      String estado,
      String title,
      String description,
      int number,
      String complement,
      double price,
      int max_guest,
      String thumbnail) async {
    final db = await database;
    int property_id = 0;
    int address_id = 0;
    await db.transaction((txn) async {
      // find address BY CEP, if not found, insert new address, and get the address_id, else get the address_id

      final address =
          await txn.rawQuery('SELECT id FROM address WHERE cep = ?', [cep]);

      if (address.isNotEmpty) {
        address_id = address.first['id'] as int;
      } else {
        address_id = await txn.rawInsert(
            'INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES(?, ?, ?, ?, ?, ?)',
            [cep, logradouro, bairro, localidade, uf, estado]);
      }

      property_id = await txn.rawInsert(
          'INSERT INTO property(user_id, address_id, title, description, number, complement, price, max_guest, thumbnail) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            user_id,
            address_id,
            title,
            description,
            number,
            complement,
            price,
            max_guest,
            thumbnail.trim() == '' ? 'image_path' : thumbnail
          ]);
    });

    return Property(
        id: property_id,
        user_id: user_id,
        address_id: address_id,
        title: title,
        description: description,
        number: number,
        complement: complement,
        price: price,
        max_guest: max_guest,
        thumbnail: thumbnail);
  }

  // Adicionar imagens a uma propriedade
  Future<void> addImages(int property_id, List<String> images) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var image in images) {
        await txn.rawInsert(
            'INSERT INTO images(property_id, path) VALUES(?, ?)',
            [property_id, image]);
      }
    });
  }

  // Obter todas as propriedades de um usuário
  Future<List<Property>> getProperties(int user_id) async {
    final db = await database;
    final properties = await db
        .rawQuery('SELECT * FROM property WHERE user_id = ?', [user_id]);

    final List<Property> propertiesList = [];
    for (var property in properties) {
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
          thumbnail: property['thumbnail'] as String));
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

  // Remover propriedade
  Future<void> removeProperty(int propertyId) async {
    final db = await database;
    await db.transaction((txn) async {
      final property = await txn.rawQuery(
          'SELECT address_id FROM property WHERE id = ?', [propertyId]);

      if (property.isNotEmpty) {
        await txn.rawDelete(
            'DELETE FROM images WHERE property_id = ?', [propertyId]);
        await txn.rawDelete('DELETE FROM property WHERE id = ?', [propertyId]);
      }
    });
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
    );
  }

  // Editar propriedade
  Future<void> editProperty({
    required int propertyId,
    required String cep,
    required String logradouro,
    required String bairro,
    required String localidade,
    required String uf,
    required String estado,
    required String title,
    required String description,
    required int number,
    String? complement,
    required double price,
    required int max_guest,
    required String thumbnail,
    // required List<String> images,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final propertyRow = await txn.rawQuery(
        'SELECT address_id FROM property WHERE id = ?',
        [propertyId],
      );
      if (propertyRow.isEmpty) throw Exception('Propriedade não encontrada');
      final addressId = propertyRow.first['address_id'] as int;

      print("cheguei aqui 1");
      final addressCepResult = await txn
          .rawQuery('SELECT cep FROM address WHERE id = ?', [addressId]);
      String oldCep = addressCepResult.first['cep'] as String;

      if (cep != oldCep) {
        final address =
            await txn.rawQuery('SELECT id FROM address WHERE cep = ?', [cep]);
        if (address.isNotEmpty) {
          await txn.rawUpdate('UPDATE property SET address_id = ? WHERE id = ?',
              [address.first['id'], propertyId]);
        } else {
          int new_address_id = await txn.rawInsert(
              'INSERT INTO address(cep, logradouro, bairro, localidade, uf, estado) VALUES(?, ?, ?, ?, ?, ?)',
              [cep, logradouro, bairro, localidade, uf, estado]);
          await txn.rawUpdate('UPDATE property SET address_id = ? WHERE id = ?',
              [new_address_id, propertyId]);
        }
      }
      print("cheguei aqui 2");
      await txn.rawUpdate(
        'UPDATE property SET title = ?, description = ?, number = ?, complement = ?, price = ?, max_guest = ?, thumbnail = ? WHERE id = ?',
        [
          title,
          description,
          number,
          complement,
          price,
          max_guest,
          thumbnail.trim() == '' ? 'image_path' : thumbnail,
          propertyId
        ],
      );

      // await txn.rawDelete(
      //   'DELETE FROM images WHERE property_id = ?',
      //   [propertyId],
      // );
      // for (var image in images) {
      //   await txn.rawInsert(
      //     'INSERT INTO images(property_id, path) VALUES(?, ?)',
      //     [propertyId, image],
      //   );
      // }
    });
  }
}

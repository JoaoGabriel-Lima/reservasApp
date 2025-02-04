import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reservas_admin/routes/anunciar/cadastrar_propriedade.dart';
import 'package:reservas_admin/routes/anunciar/minhas_propriedades.dart';
import 'package:reservas_admin/routes/login.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future main() async {
  if (kIsWeb) {
    // Use web implementation on the web.
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Use ffi on Linux and Windows.
    if (Platform.isLinux || Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
      sqfliteFfiInit();
    }
  }
  runApp(MaterialApp(
    title: "AJY Reservas",
    theme: ThemeData(
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16.0),
      ),
    ),
    debugShowCheckedModeBanner: false,
    initialRoute: Login.route,
    routes: {
      Login.route: (context) => const Login(),
      MinhasPropriedades.route: (context) => const MinhasPropriedades(),
      CadastrarPropriedade.route: (context) => const CadastrarPropriedade(),
    },
  ));
}

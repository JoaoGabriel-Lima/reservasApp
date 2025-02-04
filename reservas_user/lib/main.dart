import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reservas_user/routes/alugar/listaPropriedades.dart';
import 'package:reservas_user/routes/cadastro.dart';
import 'package:reservas_user/routes/login.dart';
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

    if (Platform.isAndroid) {
      // Initialize FFI
      print("Initialized");
      // databaseFactory = databaseFactoryFfi;
      sqfliteFfiInit();
    }
  }
  runApp(MaterialApp(
    title: "AJY Reservas",
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue[600],
      scaffoldBackgroundColor: const Color.fromARGB(255, 1, 12, 27),
      hintColor: Colors.white,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16.0),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.blue),
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom().copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.blue.withOpacity(
                  0.12); // change this to your desired ripple color
            }
            return null;
          }),
          foregroundColor:
              WidgetStateProperty.resolveWith<Color?>((states) => Colors.blue),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom().copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.blue.withOpacity(
                  0.12); // change this to your desired ripple color
            }
            return null;
          }),
          foregroundColor:
              WidgetStateProperty.resolveWith<Color?>((states) => Colors.blue),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.blue,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      drawerTheme: const DrawerThemeData(surfaceTintColor: Colors.blue),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom().copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.blue.withOpacity(
                  0.12); // change this to your desired ripple color
            }
            return null;
          }),
          foregroundColor:
              WidgetStateProperty.resolveWith<Color?>((states) => Colors.blue),
        ),
      ),
    ),
    themeMode: ThemeMode.dark,
    debugShowCheckedModeBanner: false,
    initialRoute: Login.route,
    routes: {
      Login.route: (context) => const Login(),
      Cadastro.route: (context) => const Cadastro(),
      ListaPropriedades.route: (context) => const ListaPropriedades(),
    },
  ));
}

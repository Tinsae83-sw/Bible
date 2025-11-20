import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 22, 19, 227),
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 26, 15, 225),
    secondary: Color.fromARGB(255, 7, 22, 230),
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 22, 47, 231),
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
        fontSize: 16.0, color: Colors.black87, fontFamily: 'AbyssinicaSIL'),
    bodyMedium: TextStyle(
        fontSize: 14.0, color: Colors.black87, fontFamily: 'AbyssinicaSIL'),
  ),
  fontFamily: 'AbyssinicaSIL',
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blueGrey,
  colorScheme: const ColorScheme.dark(
    primary: Colors.blueGrey,
    secondary: Color.fromARGB(255, 52, 39, 240),
  ),
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
        fontSize: 16.0, color: Colors.white, fontFamily: 'AbyssinicaSIL'),
    bodyMedium: TextStyle(
        fontSize: 14.0, color: Colors.white70, fontFamily: 'AbyssinicaSIL'),
  ),
  fontFamily: 'AbyssinicaSIL',
);

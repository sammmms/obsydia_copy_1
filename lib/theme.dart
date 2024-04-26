import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
    fontFamily: 'Quicksand',
    scaffoldBackgroundColor: Colors.grey.shade200,
    dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle:
            TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.bold)),
    textTheme: const TextTheme(
            bodyLarge: TextStyle(fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontWeight: FontWeight.bold),
            bodySmall: TextStyle(fontWeight: FontWeight.bold))
        .apply(bodyColor: Colors.black54),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.green.shade50),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )))),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        disabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade50),
    useMaterial3: true,
    chipTheme: ChipThemeData(
        side: const BorderSide(color: Colors.transparent),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));

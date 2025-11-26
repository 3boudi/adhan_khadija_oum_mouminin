import 'package:flutter/material.dart';
import '../pages/home/home.dart';

void main() {
  runApp(
    MaterialApp(
      home: const Home(),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
    ),
  );
}

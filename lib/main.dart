import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventario',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const HomePage());
  }
}

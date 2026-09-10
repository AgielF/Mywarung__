import 'package:flutter/material.dart';
import 'ui/home/home_screen.dart';

void main() {
  runApp(const POSWarungAIApp());
}

class POSWarungAIApp extends StatelessWidget {
  const POSWarungAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Warung AI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

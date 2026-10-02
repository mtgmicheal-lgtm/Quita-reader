import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MikroTikUserManagerApp());
}

class MikroTikUserManagerApp extends StatelessWidget {
  const MikroTikUserManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MikroTik User Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}

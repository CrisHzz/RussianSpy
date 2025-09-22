import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Russian Spy',
      home: Scaffold(
        appBar: AppBar(title: const Text('Russian Spy')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Russian Spy', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              Image.asset('assets/russian_flag.png', width: 100),
            ],
          ),
        ),
      ),
    );
  }
}

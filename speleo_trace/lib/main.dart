import 'package:flutter/material.dart';

import 'views/triangulation_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpeleoTraceApp());
}

class SpeleoTraceApp extends StatelessWidget {
  const SpeleoTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speleo Trace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TriangulationHomePage(),
    );
  }
}

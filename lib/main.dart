import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/state_filtro.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider<StateFiltro>(
      create: (_) => StateFiltro(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Engenharia .NET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.yellow.shade700,
          secondary: Colors.grey.shade300,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.yellow.shade700,
          foregroundColor: Colors.black,
        ),
        // Aqui:
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
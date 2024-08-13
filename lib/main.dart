import 'package:flutter/material.dart';
import 'package:meena/feature/views/home_screen.dart';
import 'package:meena/feature/services/api_service.dart';

void main() {
  var apiService = const ApiService();
  runApp(
    MyApp(
      apiService: apiService,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeApp(apiService: apiService),
    );
  }
}

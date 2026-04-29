import 'package:flutter/material.dart';
import 'package:flutter_application_mbahmeth/screens/welcome_screen.dart';
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Mbahmeth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

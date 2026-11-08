import 'package:flutter/material.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserProviderWrapper(
      child: ThemedApp(),
    );
  }
}

// Latihan 1: MaterialApp berada di bawah UserProviderWrapper
// agar bisa membaca isDarkMode lewat UserProvider.of(context)
class ThemedApp extends StatelessWidget {
  const ThemedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = UserProvider.of(context);

    return MaterialApp(
      title: 'State & Preferences',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

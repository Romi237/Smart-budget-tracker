import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart';
import 'services/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle any uncaught errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.red,
        child: Center(
          child: Text(
            'An error occurred. Please restart the app.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Budget Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/ad_service.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for consistent calculator layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Google Mobile Ads SDK safely
  await AdService.initialize();

  // Load user saved currency preference
  final prefs = await SharedPreferences.getInstance();
  final String savedCurrency = prefs.getString('selected_currency') ?? '\$';

  runApp(SmartLoanPlannerApp(initialCurrency: savedCurrency));
}

class SmartLoanPlannerApp extends StatelessWidget {
  final String initialCurrency;

  const SmartLoanPlannerApp({Key? key, required this.initialCurrency})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Loan & EMI Planner',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Deep Navy / Royal Blue
          brightness: Brightness.light,
          primary: const Color(0xFF1E3A8A),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: HomeView(initialCurrency: initialCurrency),
    );
  }
}

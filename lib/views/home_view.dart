import 'package:flutter/material.dart';
import 'compare_loans_view.dart';
import 'emi_calculator_view.dart';
import 'prepayment_calculator_view.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  final String initialCurrency;

  const HomeView({Key? key, required this.initialCurrency}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  late String _currencySymbol;

  @override
  void initState() {
    super.initState();
    _currencySymbol = widget.initialCurrency;
  }

  void _onCurrencyChanged(String newSymbol) {
    setState(() {
      _currencySymbol = newSymbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      EmiCalculatorView(currencySymbol: _currencySymbol),
      PrepaymentCalculatorView(currencySymbol: _currencySymbol),
      CompareLoansView(currencySymbol: _currencySymbol),
      SettingsView(
        currentCurrency: _currencySymbol,
        onCurrencyChanged: _onCurrencyChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'EMI Calc',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Prepay',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows_outlined),
            selectedIcon: Icon(Icons.compare_arrows),
            label: 'Compare',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

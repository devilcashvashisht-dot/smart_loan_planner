import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';

class SettingsView extends StatefulWidget {
  final String currentCurrency;
  final Function(String) onCurrencyChanged;

  const SettingsView({
    Key? key,
    required this.currentCurrency,
    required this.onCurrencyChanged,
  }) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar (\$)'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro (€)'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound (£)'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee (₹)'},
    {'code': 'CAD', 'symbol': 'CA\$', 'name': 'Canadian Dollar (CA\$)'},
    {'code': 'AUD', 'symbol': 'AU\$', 'name': 'Australian Dollar (AU\$)'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen (¥)'},
    {'code': 'PHP', 'symbol': '₱', 'name': 'Philippine Peso (₱)'},
    {'code': 'PKR', 'symbol': '₨', 'name': 'Pakistani Rupee (₨)'},
    {'code': 'AED', 'symbol': 'AED', 'name': 'UAE Dirham (AED)'},
  ];

  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currentCurrency;
  }

  Future<void> _updateCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', symbol);
    setState(() => _selectedCurrency = symbol);
    widget.onCurrencyChanged(symbol);
  }

  void _showAdFreeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go Ad-Free Pro'),
        content: const Text(
          'Remove all banner, interstitial, and video ads permanently with a one-time purchase.\n\nEnjoy an ultra-clean, uninterrupted financial planning experience.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Simulates in-app purchase activation
              setState(() {
                AdService.isAdFreeUser = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ad-Free Mode activated! Ads are now disabled.'),
                ),
              );
            },
            child: const Text('Unlock for \$2.99'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Smart Loan & EMI Financial Planner respects your privacy.\n\n'
            '1. Offline Processing: All your loan calculations, figures, and amortization details are computed locally on your device and are never transmitted to external servers.\n\n'
            '2. Advertising: We use Google AdMob to display banner, interstitial, and rewarded ads. Google AdMob may use device identifiers to serve non-personalized or personalized ads in accordance with Google Play developer policies.\n\n'
            '3. Data Collection: We do not collect, store, sell, or rent any of your personal financial records.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Go Ad-Free Upgrade Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade800, Colors.indigo.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Unlock Ad-Free Experience',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'One-time purchase, no subscriptions',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade900,
                  ),
                  onPressed: _showAdFreeDialog,
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Currency Settings
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Preferred Currency Symbol'),
            subtitle: Text('Currently: $_selectedCurrency'),
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              underline: const SizedBox(),
              items: _currencies.map((item) {
                return DropdownMenuItem<String>(
                  value: item['symbol'],
                  child: Text(item['name']!),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) _updateCurrency(val);
              },
            ),
          ),

          const Divider(),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Google Play compliant & transparent'),
            trailing: const Icon(Icons.chevron_right),
            onPressed: _showPrivacyPolicy,
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Smart Loan Planner'),
            subtitle: const Text('Version 1.0.0 • 100% Offline • High Accuracy'),
            trailing: const Icon(Icons.verified, color: Colors.green),
          ),
        ],
      ),
    );
  }
}

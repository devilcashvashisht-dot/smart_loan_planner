import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../models/loan_models.dart';
import '../services/ad_service.dart';
import '../services/calculator_service.dart';

class PrepaymentCalculatorView extends StatefulWidget {
  final String currencySymbol;

  const PrepaymentCalculatorView({Key? key, required this.currencySymbol})
      : super(key: key);

  @override
  State<PrepaymentCalculatorView> createState() =>
      _PrepaymentCalculatorViewState();
}

class _PrepaymentCalculatorViewState extends State<PrepaymentCalculatorView> {
  final TextEditingController _amountController =
      TextEditingController(text: '200000');
  final TextEditingController _rateController =
      TextEditingController(text: '8.0');
  final TextEditingController _tenureController =
      TextEditingController(text: '20');
  final TextEditingController _monthlyPrepayController =
      TextEditingController(text: '150');
  final TextEditingController _lumpSumController =
      TextEditingController(text: '5000');
  final TextEditingController _lumpSumMonthController =
      TextEditingController(text: '12');

  late PrepaymentResult _result;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _recalculate();
    _initBanner();
  }

  void _initBanner() {
    if (AdService.isAdFreeUser) return;
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) => setState(() => _isBannerLoaded = true),
      onAdFailedToLoad: (ad, error) => ad.dispose(),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _monthlyPrepayController.dispose();
    _lumpSumController.dispose();
    _lumpSumMonthController.dispose();
    super.dispose();
  }

  void _recalculate() {
    double principal = double.tryParse(_amountController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    int tenureYears = int.tryParse(_tenureController.text) ?? 1;
    double monthlyPrepay = double.tryParse(_monthlyPrepayController.text) ?? 0;
    double lumpSum = double.tryParse(_lumpSumController.text) ?? 0;
    int lumpSumMonth = int.tryParse(_lumpSumMonthController.text) ?? 1;

    setState(() {
      _result = CalculatorService.calculatePrepayment(
        principal: principal,
        annualInterestRate: rate,
        tenureMonths: tenureYears * 12,
        monthlyPrepayment: monthlyPrepay,
        oneTimePrepayment: lumpSum,
        oneTimePrepaymentMonth: lumpSumMonth,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prepayment & Early Payoff',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Savings Highlight Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.emerald ?? Colors.green.shade700,
                          Colors.teal.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL INTEREST SAVED',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.currencySymbol} ${_currencyFormat.format(_result.interestSaved)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Time Saved',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_result.monthsSaved / 12).toStringAsFixed(1)} Years (${_result.monthsSaved} mo)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                height: 30, width: 1, color: Colors.white30),
                            Column(
                              children: [
                                const Text(
                                  'New Tenure',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_result.newTenureMonths / 12).toStringAsFixed(1)} Years',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Loan Details Inputs
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loan Baseline',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Loan Amount',
                              prefixText: '${widget.currencySymbol} ',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) => _recalculate(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _rateController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Interest Rate',
                                    suffixText: '%',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (_) => _recalculate(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _tenureController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Tenure (Years)',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (_) => _recalculate(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prepayment Inputs
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Extra Prepayment Strategy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _monthlyPrepayController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Extra Monthly Payment',
                              prefixText: '${widget.currencySymbol} ',
                              border: const OutlineInputBorder(),
                              helperText: 'Add directly towards principal',
                            ),
                            onChanged: (_) => _recalculate(),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _lumpSumController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'One-Time Lump Sum',
                                    prefixText: '${widget.currencySymbol} ',
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (_) => _recalculate(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _lumpSumMonthController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'In Month #',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (_) => _recalculate(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom AdMob Banner
          if (_isBannerLoaded && _bannerAd != null)
            SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}

extension ColorsExt on Colors {
  static Color? get emerald => const Color(0xFF059669);
}

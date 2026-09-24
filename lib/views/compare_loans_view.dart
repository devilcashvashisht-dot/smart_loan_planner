import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../models/loan_models.dart';
import '../services/ad_service.dart';
import '../services/calculator_service.dart';

class CompareLoansView extends StatefulWidget {
  final String currencySymbol;

  const CompareLoansView({Key? key, required this.currencySymbol})
      : super(key: key);

  @override
  State<CompareLoansView> createState() => _CompareLoansViewState();
}

class _CompareLoansViewState extends State<CompareLoansView> {
  // Loan 1
  final TextEditingController _amount1 = TextEditingController(text: '150000');
  final TextEditingController _rate1 = TextEditingController(text: '7.5');
  final TextEditingController _tenure1 = TextEditingController(text: '15');

  // Loan 2
  final TextEditingController _amount2 = TextEditingController(text: '150000');
  final TextEditingController _rate2 = TextEditingController(text: '8.2');
  final TextEditingController _tenure2 = TextEditingController(text: '20');

  late ComparisonResult _comparison;
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
    _amount1.dispose();
    _rate1.dispose();
    _tenure1.dispose();
    _amount2.dispose();
    _rate2.dispose();
    _tenure2.dispose();
    super.dispose();
  }

  void _recalculate() {
    double p1 = double.tryParse(_amount1.text) ?? 0;
    double r1 = double.tryParse(_rate1.text) ?? 0;
    int t1 = (int.tryParse(_tenure1.text) ?? 1) * 12;

    double p2 = double.tryParse(_amount2.text) ?? 0;
    double r2 = double.tryParse(_rate2.text) ?? 0;
    int t2 = (int.tryParse(_tenure2.text) ?? 1) * 12;

    setState(() {
      _comparison = CalculatorService.compareLoans(
        principal1: p1,
        rate1: r1,
        tenureMonths1: t1,
        principal2: p2,
        rate2: r2,
        tenureMonths2: t2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOption1Winner = _comparison.isLoan1Cheaper;
    final winnerName = isOption1Winner ? 'Option A' : 'Option B';
    final savings = _comparison.totalPaymentDifference;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Loan Offers',
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
                  // Winner & Savings Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isOption1Winner
                          ? Colors.blue.shade900
                          : Colors.indigo.shade900,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '$winnerName is Cheaper!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Saves ${widget.currencySymbol} ${_currencyFormat.format(savings)} in Total Cost',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Side by Side Input Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Option A
                      Expanded(
                        child: _buildLoanInputCard(
                          title: 'Option A',
                          color: Colors.blue.shade700,
                          amountCtrl: _amount1,
                          rateCtrl: _rate1,
                          tenureCtrl: _tenure1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Option B
                      Expanded(
                        child: _buildLoanInputCard(
                          title: 'Option B',
                          color: Colors.indigo.shade700,
                          amountCtrl: _amount2,
                          rateCtrl: _rate2,
                          tenureCtrl: _tenure2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Comparison Table
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Side-by-Side Comparison',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildComparisonRow(
                            'Monthly EMI',
                            '${widget.currencySymbol} ${_currencyFormat.format(_comparison.loan1.monthlyEmi)}',
                            '${widget.currencySymbol} ${_currencyFormat.format(_comparison.loan2.monthlyEmi)}',
                            is1Better: _comparison.loan1.monthlyEmi <
                                _comparison.loan2.monthlyEmi,
                          ),
                          const Divider(height: 20),
                          _buildComparisonRow(
                            'Total Interest',
                            '${widget.currencySymbol} ${_currencyFormat.format(_comparison.loan1.totalInterest)}',
                            '${widget.currencySymbol} ${_currencyFormat.format(_comparison.loan2.totalInterest)}',
                            is1Better: _comparison.loan1.totalInterest <
                                _comparison.loan2.totalInterest,
                          ),
                          const Divider(height: 20),
                          _buildComparisonRow(
                            'Total Repayment',
                            '${widget.currencySymbol} ${_currencyFormat.format(_comparison.loan1.totalPayment)}',
                            '${widget.currencySymbol} ${_currencyFormat.format(_comparison.loan2.totalPayment)}',
                            is1Better: _comparison.loan1.totalPayment <
                                _comparison.loan2.totalPayment,
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

  Widget _buildLoanInputCard({
    required String title,
    required Color color,
    required TextEditingController amountCtrl,
    required TextEditingController rateCtrl,
    required TextEditingController tenureCtrl,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _recalculate(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rateCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Rate %',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _recalculate(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tenureCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Yrs',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _recalculate(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String val1,
    String val2, {
    required bool is1Better,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              val1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: is1Better ? FontWeight.bold : FontWeight.normal,
                color: is1Better ? Colors.green.shade700 : null,
              ),
            ),
            Text(
              val2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: !is1Better ? FontWeight.bold : FontWeight.normal,
                color: !is1Better ? Colors.green.shade700 : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

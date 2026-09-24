import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../models/loan_models.dart';
import '../services/ad_service.dart';
import '../services/calculator_service.dart';
import 'amortization_view.dart';

class EmiCalculatorView extends StatefulWidget {
  final String currencySymbol;

  const EmiCalculatorView({Key? key, required this.currencySymbol})
      : super(key: key);

  @override
  State<EmiCalculatorView> createState() => _EmiCalculatorViewState();
}

class _EmiCalculatorViewState extends State<EmiCalculatorView> {
  final TextEditingController _amountController =
      TextEditingController(text: '100000');
  final TextEditingController _rateController =
      TextEditingController(text: '8.5');
  final TextEditingController _tenureController =
      TextEditingController(text: '5');

  bool _isTenureInYears = true;
  late CalculationResult _result;
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
      onAdLoaded: (ad) {
        setState(() {
          _isBannerLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _recalculate() {
    double principal = double.tryParse(_amountController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    int tenureInput = int.tryParse(_tenureController.text) ?? 1;

    int tenureMonths = _isTenureInYears ? (tenureInput * 12) : tenureInput;
    if (tenureMonths <= 0) tenureMonths = 1;

    setState(() {
      _result = CalculatorService.calculateEmi(
        principal: principal,
        annualInterestRate: rate,
        tenureMonths: tenureMonths,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart EMI Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Primary EMI Result Highlight Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'MONTHLY PAYMENT (EMI)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.currencySymbol} ${_currencyFormat.format(_result.monthlyEmi)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCardSubStat(
                              'Total Interest',
                              '${widget.currencySymbol} ${_currencyFormat.format(_result.totalInterest)}',
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.white30,
                            ),
                            _buildCardSubStat(
                              'Total Payment',
                              '${widget.currencySymbol} ${_currencyFormat.format(_result.totalPayment)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Input Form
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Loan Amount Field
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Loan Amount',
                              prefixText: '${widget.currencySymbol} ',
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.account_balance),
                            ),
                            onChanged: (_) => _recalculate(),
                          ),
                          const SizedBox(height: 14),

                          // Interest Rate Field
                          TextField(
                            controller: _rateController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Interest Rate (% p.a.)',
                              suffixText: '%',
                              border: const OutlineInputBorder(),
                              suffixIcon: Icon(Icons.percent),
                            ),
                            onChanged: (_) => _recalculate(),
                          ),
                          const SizedBox(height: 14),

                          // Loan Tenure Field with Years/Months toggle
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _tenureController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Loan Tenure',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: const Icon(Icons.timer_outlined),
                                  ),
                                  onChanged: (_) => _recalculate(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: SegmentedButton<bool>(
                                  segments: const [
                                    ButtonSegment(
                                      value: true,
                                      label: Text('Yrs'),
                                    ),
                                    ButtonSegment(
                                      value: false,
                                      label: Text('Mo'),
                                    ),
                                  ],
                                  selected: {_isTenureInYears},
                                  onSelectionChanged: (selection) {
                                    setState(() {
                                      _isTenureInYears = selection.first;
                                      _recalculate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Breakdown Donut Chart
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
                            'Repayment Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 36,
                                      sections: [
                                        PieChartSectionData(
                                          color: theme.colorScheme.primary,
                                          value: _result.principalPercentage,
                                          title:
                                              '${_result.principalPercentage.toStringAsFixed(0)}%',
                                          radius: 38,
                                          titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          color: Colors.orangeAccent,
                                          value: _result.interestPercentage,
                                          title:
                                              '${_result.interestPercentage.toStringAsFixed(0)}%',
                                          radius: 38,
                                          titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLegendItem(
                                        'Principal Amount',
                                        theme.colorScheme.primary,
                                        '${widget.currencySymbol} ${_currencyFormat.format(_result.principal)}',
                                      ),
                                      const SizedBox(height: 12),
                                      _buildLegendItem(
                                        'Total Interest',
                                        Colors.orangeAccent,
                                        '${widget.currencySymbol} ${_currencyFormat.format(_result.totalInterest)}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Button to Amortization Schedule
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text(
                      'View Amortization Schedule & PDF',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      AdService.showInterstitialOnPacedAction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AmortizationView(
                            result: _result,
                            currencySymbol: widget.currencySymbol,
                          ),
                        ),
                      );
                    },
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

  Widget _buildCardSubStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color, String amount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 3, right: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

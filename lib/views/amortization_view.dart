import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/loan_models.dart';
import '../services/ad_service.dart';
import '../services/pdf_service.dart';

class AmortizationView extends StatefulWidget {
  final CalculationResult result;
  final String currencySymbol;

  const AmortizationView({
    Key? key,
    required this.result,
    required this.currencySymbol,
  }) : super(key: key);

  @override
  State<AmortizationView> createState() => _AmortizationViewState();
}

class _AmortizationViewState extends State<AmortizationView> {
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00');
  bool _isExporting = false;

  void _triggerPdfExport() {
    setState(() => _isExporting = true);

    // Monetization gate: Show rewarded ad to unlock PDF export
    AdService.showRewardedAd(
      onRewardEarned: () async {
        try {
          await PdfService.exportAmortizationPdf(
            result: widget.result,
            currencySymbol: widget.currencySymbol,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to export PDF: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isExporting = false);
        }
      },
      onAdUnavailableOrDismissed: () async {
        // Fallback: Export anyway if ad couldn't load
        try {
          await PdfService.exportAmortizationPdf(
            result: widget.result,
            currencySymbol: widget.currencySymbol,
          );
        } finally {
          if (mounted) setState(() => _isExporting = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amortization Schedule'),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf),
            onPressed: _isExporting ? null : _triggerPdfExport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Informational Banner about Export
          Container(
            padding: const pwInsetsSymmetric(16, 10),
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Full ${widget.result.tenureMonths}-month schedule. Tap PDF to save or share.',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isExporting ? null : _triggerPdfExport,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('PDF', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // Schedule Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.surfaceVariant,
            child: Row(
              children: const [
                SizedBox(
                  width: 44,
                  child: Text(
                    'Mo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Principal',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Interest',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Balance',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Schedule List
          Expanded(
            child: ListView.separated(
              itemCount: widget.result.schedule.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final row = widget.result.schedule[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          '#${row.month}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _currencyFormat.format(row.principalPaid),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _currencyFormat.format(row.interestPaid),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          _currencyFormat.format(row.closingBalance),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isExporting ? null : _triggerPdfExport,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Export Statement'),
      ),
    );
  }
}

class pwInsetsSymmetric extends EdgeInsets {
  const pwInsetsSymmetric(double horizontal, double vertical)
      : super.symmetric(horizontal: horizontal, vertical: vertical);
}

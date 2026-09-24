import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/loan_models.dart';

class PdfService {
  /// Generates and prompts the user to share or print a PDF amortization statement.
  static Future<void> exportAmortizationPdf({
    required CalculationResult result,
    required String currencySymbol,
  }) async {
    final pdf = pw.Document();
    final numberFormat = NumberFormat('#,##0.00');

    // Divide schedule into chunks for paginated PDF tables
    const int rowsPerPage = 28;
    final totalPages = (result.schedule.length / rowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final start = pageIndex * rowsPerPage;
      final end = (start + rowsPerPage > result.schedule.length)
          ? result.schedule.length
          : start + rowsPerPage;
      final pageRows = result.schedule.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (pageIndex == 0) ...[
                  // Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'LOAN AMORTIZATION SCHEDULE',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Generated on ${DateFormat.yMMMd().format(DateTime.now())}',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue50,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'CONFIDENTIAL / PERSONAL',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),

                  // Summary Card
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                      color: PdfColors.grey100,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'Principal Amount',
                          '$currencySymbol ${numberFormat.format(result.principal)}',
                        ),
                        _buildSummaryItem(
                          'Interest Rate',
                          '${result.annualInterestRate.toStringAsFixed(2)}% p.a.',
                        ),
                        _buildSummaryItem(
                          'Tenure',
                          '${result.tenureMonths} Months (${(result.tenureMonths / 12).toStringAsFixed(1)} Yrs)',
                        ),
                        _buildSummaryItem(
                          'Monthly EMI',
                          '$currencySymbol ${numberFormat.format(result.monthlyEmi)}',
                        ),
                        _buildSummaryItem(
                          'Total Interest',
                          '$currencySymbol ${numberFormat.format(result.totalInterest)}',
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ] else ...[
                  // Continuation header for subsequent pages
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Amortization Schedule (Continued)',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.Text(
                        'Page ${pageIndex + 1} of $totalPages',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                ],

                // Schedule Table
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  cellStyle: const pw.TextStyle(fontSize: 7.5),
                  cellHeight: 18,
                  cellAlignment: pw.Alignment.centerRight,
                  headers: [
                    'Month',
                    'Opening Balance',
                    'EMI',
                    'Principal',
                    'Interest',
                    'Closing Balance',
                  ],
                  data: pageRows.map((row) {
                    return [
                      '#${row.month}',
                      '$currencySymbol${numberFormat.format(row.openingBalance)}',
                      '$currencySymbol${numberFormat.format(row.emi)}',
                      '$currencySymbol${numberFormat.format(row.principalPaid)}',
                      '$currencySymbol${numberFormat.format(row.interestPaid)}',
                      '$currencySymbol${numberFormat.format(row.closingBalance)}',
                    ];
                  }).toList(),
                ),

                pw.Spacer(),
                // Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Smart Loan & EMI Financial Planner - Verified Offline Calculation',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                    ),
                    pw.Text(
                      'Page ${pageIndex + 1} of $totalPages',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Loan_Amortization_Schedule_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildSummaryItem(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_loan_planner/models/loan_models.dart';
import 'package:smart_loan_planner/services/calculator_service.dart';

void main() {
  group('CalculatorService Tests', () {
    test('Standard EMI calculation matches financial benchmark', () {
      // Benchmark: $100,000 at 10% for 12 months
      // Standard monthly EMI: ~$8791.59
      final result = CalculatorService.calculateEmi(
        principal: 100000,
        annualInterestRate: 10.0,
        tenureMonths: 12,
      );

      expect(result.monthlyEmi, closeTo(8791.59, 0.10));
      expect(result.schedule.length, equals(12));
      expect(result.schedule.last.closingBalance, equals(0.0));
      expect(result.totalPayment, greaterThan(100000));
      expect(result.totalInterest, closeTo(5499.06, 1.0));
    });

    test('Zero interest rate returns linear division', () {
      final result = CalculatorService.calculateEmi(
        principal: 12000,
        annualInterestRate: 0.0,
        tenureMonths: 12,
      );

      expect(result.monthlyEmi, equals(1000.0));
      expect(result.totalInterest, equals(0.0));
      expect(result.totalPayment, equals(12000.0));
      expect(result.schedule.last.closingBalance, equals(0.0));
    });

    test('Prepayment shortens tenure and saves interest', () {
      final prepayResult = CalculatorService.calculatePrepayment(
        principal: 200000,
        annualInterestRate: 8.5,
        tenureMonths: 240, // 20 years
        monthlyPrepayment: 200, // Extra $200 every month
      );

      expect(prepayResult.monthsSaved, greaterThan(0));
      expect(prepayResult.interestSaved, greaterThan(0));
      expect(prepayResult.newTenureMonths, lessThan(240));
    });

    test('Loan comparison accurately flags cheaper option', () {
      final comparison = CalculatorService.compareLoans(
        principal1: 100000,
        rate1: 7.0,
        tenureMonths1: 180,
        principal2: 100000,
        rate2: 9.0,
        tenureMonths2: 180,
      );

      expect(comparison.isLoan1Cheaper, isTrue);
      expect(comparison.totalPaymentDifference, greaterThan(0));
    });
  });
}

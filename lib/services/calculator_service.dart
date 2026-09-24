import 'dart:math';
import '../models/loan_models.dart';

class CalculatorService {
  /// Calculates standard Equated Monthly Installment (EMI) and generates full amortization schedule.
  static CalculationResult calculateEmi({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    if (principal <= 0 || tenureMonths <= 0) {
      return CalculationResult(
        principal: principal,
        annualInterestRate: annualInterestRate,
        tenureMonths: tenureMonths,
        monthlyEmi: 0,
        totalInterest: 0,
        totalPayment: principal,
        schedule: [],
      );
    }

    double monthlyRate = (annualInterestRate / 100) / 12;
    double emi;

    if (annualInterestRate == 0) {
      emi = principal / tenureMonths;
    } else {
      double rateFactor = pow(1 + monthlyRate, tenureMonths).toDouble();
      emi = principal * monthlyRate * rateFactor / (rateFactor - 1);
    }

    List<MonthlyAmortization> schedule = [];
    double currentBalance = principal;
    double totalInterest = 0;

    for (int month = 1; month <= tenureMonths; month++) {
      double interestForMonth = currentBalance * monthlyRate;
      double principalForMonth = emi - interestForMonth;

      if (month == tenureMonths || principalForMonth > currentBalance) {
        principalForMonth = currentBalance;
        emi = principalForMonth + interestForMonth;
      }

      double closingBalance = currentBalance - principalForMonth;
      if (closingBalance < 0.01) {
        closingBalance = 0;
      }

      totalInterest += interestForMonth;

      schedule.add(
        MonthlyAmortization(
          month: month,
          openingBalance: currentBalance,
          emi: emi,
          principalPaid: principalForMonth,
          interestPaid: interestForMonth,
          closingBalance: closingBalance,
        ),
      );

      currentBalance = closingBalance;
      if (currentBalance <= 0) break;
    }

    double totalPayment = principal + totalInterest;

    return CalculationResult(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
      monthlyEmi: emi,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      schedule: schedule,
    );
  }

  /// Calculates the savings (money and time) if user pays extra towards the principal.
  static PrepaymentResult calculatePrepayment({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
    double monthlyPrepayment = 0,
    double oneTimePrepayment = 0,
    int oneTimePrepaymentMonth = 1,
  }) {
    CalculationResult original = calculateEmi(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
    );

    double monthlyRate = (annualInterestRate / 100) / 12;
    double currentBalance = principal;
    double newTotalInterest = 0;
    List<MonthlyAmortization> newSchedule = [];
    int actualMonth = 0;

    while (currentBalance > 0.01 && actualMonth < (tenureMonths * 2)) {
      actualMonth++;
      double interestForMonth = currentBalance * monthlyRate;
      double standardEmi = original.monthlyEmi;

      double extraThisMonth = monthlyPrepayment;
      if (actualMonth == oneTimePrepaymentMonth) {
        extraThisMonth += oneTimePrepayment;
      }

      double totalPaymentThisMonth = standardEmi + extraThisMonth;
      double principalForMonth = totalPaymentThisMonth - interestForMonth;

      if (principalForMonth >= currentBalance) {
        principalForMonth = currentBalance;
        totalPaymentThisMonth = principalForMonth + interestForMonth;
      }

      double closingBalance = currentBalance - principalForMonth;
      if (closingBalance < 0.01) {
        closingBalance = 0;
      }

      newTotalInterest += interestForMonth;

      newSchedule.add(
        MonthlyAmortization(
          month: actualMonth,
          openingBalance: currentBalance,
          emi: totalPaymentThisMonth,
          principalPaid: principalForMonth,
          interestPaid: interestForMonth,
          closingBalance: closingBalance,
        ),
      );

      currentBalance = closingBalance;
      if (currentBalance <= 0) break;
    }

    double interestSaved = original.totalInterest - newTotalInterest;
    if (interestSaved < 0) interestSaved = 0;

    int monthsSaved = tenureMonths - actualMonth;
    if (monthsSaved < 0) monthsSaved = 0;

    return PrepaymentResult(
      originalLoan: original,
      monthlyPrepayment: monthlyPrepayment,
      oneTimePrepayment: oneTimePrepayment,
      newTotalInterest: newTotalInterest,
      interestSaved: interestSaved,
      newTenureMonths: actualMonth,
      monthsSaved: monthsSaved,
      newSchedule: newSchedule,
    );
  }

  /// Compares two different loan terms/rates side by side.
  static ComparisonResult compareLoans({
    required double principal1,
    required double rate1,
    required int tenureMonths1,
    required double principal2,
    required double rate2,
    required int tenureMonths2,
  }) {
    CalculationResult loan1 = calculateEmi(
      principal: principal1,
      annualInterestRate: rate1,
      tenureMonths: tenureMonths1,
    );

    CalculationResult loan2 = calculateEmi(
      principal: principal2,
      annualInterestRate: rate2,
      tenureMonths: tenureMonths2,
    );

    return ComparisonResult(loan1: loan1, loan2: loan2);
  }
}

class MonthlyAmortization {
  final int month;
  final double openingBalance;
  final double emi;
  final double principalPaid;
  final double interestPaid;
  final double closingBalance;

  MonthlyAmortization({
    required this.month,
    required this.openingBalance,
    required this.emi,
    required this.principalPaid,
    required this.interestPaid,
    required this.closingBalance,
  });

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'openingBalance': openingBalance,
      'emi': emi,
      'principalPaid': principalPaid,
      'interestPaid': interestPaid,
      'closingBalance': closingBalance,
    };
  }
}

class CalculationResult {
  final double principal;
  final double annualInterestRate;
  final int tenureMonths;
  final double monthlyEmi;
  final double totalInterest;
  final double totalPayment;
  final List<MonthlyAmortization> schedule;

  CalculationResult({
    required this.principal,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.monthlyEmi,
    required this.totalInterest,
    required this.totalPayment,
    required this.schedule,
  });

  double get principalPercentage => (principal / totalPayment) * 100;
  double get interestPercentage => (totalInterest / totalPayment) * 100;
}

class PrepaymentResult {
  final CalculationResult originalLoan;
  final double monthlyPrepayment;
  final double oneTimePrepayment;
  final double newTotalInterest;
  final double interestSaved;
  final int newTenureMonths;
  final int monthsSaved;
  final List<MonthlyAmortization> newSchedule;

  PrepaymentResult({
    required this.originalLoan,
    required this.monthlyPrepayment,
    required this.oneTimePrepayment,
    required this.newTotalInterest,
    required this.interestSaved,
    required this.newTenureMonths,
    required this.monthsSaved,
    required this.newSchedule,
  });
}

class ComparisonResult {
  final CalculationResult loan1;
  final CalculationResult loan2;

  ComparisonResult({required this.loan1, required this.loan2});

  double get emiDifference => (loan1.monthlyEmi - loan2.monthlyEmi).abs();
  double get interestDifference => (loan1.totalInterest - loan2.totalInterest).abs();
  double get totalPaymentDifference => (loan1.totalPayment - loan2.totalPayment).abs();

  bool get isLoan1Cheaper => loan1.totalPayment < loan2.totalPayment;
}

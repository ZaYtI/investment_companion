import 'dart:math';

import 'invalid_input_exception.dart';

const monthsPerYear = 12;

double futureValue(double monthly, double annualRate, int months) {
  if (months <= 0) {
    throw const InvalidInputException('La durée doit être positive.');
  }
  if (annualRate == 0) {
    return monthly * months;
  }
  final monthlyRate = annualRate / monthsPerYear;
  return monthly * (pow(1 + monthlyRate, months) - 1) / monthlyRate;
}

double requiredMonthly(double target, double annualRate, int months) {
  return target / futureValue(1, annualRate, months);
}

double gainsShare(double finalCapital, double totalPaid) {
  if (finalCapital <= 0) {
    throw const InvalidInputException('Le capital final doit être positif.');
  }
  return (finalCapital - totalPaid) / finalCapital;
}

double ruleOf72(double annualRatePercent) {
  if (annualRatePercent <= 0) {
    throw const InvalidInputException('Le taux doit être positif.');
  }
  return 72 / annualRatePercent;
}

bool isGoalTooEasy(double target, double monthly) {
  return monthly >= target;
}

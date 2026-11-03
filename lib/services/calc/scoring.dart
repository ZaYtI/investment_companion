import 'dart:math';

import 'invalid_input_exception.dart';

const coherenceWeight = 0.40;
const prudenceWeight = 0.35;
const composureWeight = 0.25;

const crisisCoherenceWeight = 0.60;
const crisisPrudenceWeight = 0.40;

const threeStarsScore = 80;
const twoStarsScore = 50;

const reflexSeconds = 3.0;
const thoughtfulSeconds = 12.0;
const reflexPenalty = -15;
const thoughtfulBonus = 10;

const pointsPerMonthlyMistake = 25;
const monthlyDropThreshold = -0.05;

const carefulMaxVolatility = 0.08;
const balancedMaxVolatility = 0.16;
const pointsPerExtraLossPoint = 2;

class ChallengeMeasures {
  final int coherence;
  final int prudence;
  final int composure;

  const ChallengeMeasures({
    required this.coherence,
    required this.prudence,
    required this.composure,
  });

  int get score => challengeScore(coherence, prudence, composure);
  int get stars => starsForScore(score);
}

int roundScore(double value) {
  return (value + 0.000001).round();
}

int challengeScore(int coherence, int prudence, int composure) {
  return roundScore(
    coherenceWeight * coherence +
        prudenceWeight * prudence +
        composureWeight * composure,
  );
}

int crisisScore(int coherence, int prudence) {
  return roundScore(
    crisisCoherenceWeight * coherence + crisisPrudenceWeight * prudence,
  );
}

int starsForScore(int score) {
  if (score >= threeStarsScore) return 3;
  if (score >= twoStarsScore) return 2;
  return 1;
}

int timeModifier(double seconds) {
  if (seconds < reflexSeconds) return reflexPenalty;
  if (seconds <= thoughtfulSeconds) return thoughtfulBonus;
  return 0;
}

int composureWithTime(int baseComposure, double? seconds) {
  if (seconds == null) return baseComposure;
  return (baseComposure + timeModifier(seconds)).clamp(0, 100);
}

enum MonthlyDecision { keep, pause, doubleUp }

ChallengeMeasures monthlyPlanMeasures(
  List<MonthlyDecision> decisions,
  List<double> monthlyChanges,
) {
  if (decisions.isEmpty || decisions.length != monthlyChanges.length) {
    throw const InvalidInputException('Une décision par mois est attendue.');
  }
  var kept = 0;
  var doubled = 0;
  var pausesAfterDrop = 0;
  for (var i = 0; i < decisions.length; i++) {
    switch (decisions[i]) {
      case MonthlyDecision.keep:
        kept++;
      case MonthlyDecision.doubleUp:
        doubled++;
      case MonthlyDecision.pause:
        if (monthlyChanges[i] < monthlyDropThreshold) pausesAfterDrop++;
    }
  }
  return ChallengeMeasures(
    coherence: roundScore(kept / decisions.length * 100),
    prudence: max(0, 100 - pointsPerMonthlyMistake * doubled),
    composure: max(0, 100 - pointsPerMonthlyMistake * pausesAfterDrop),
  );
}

enum RiskBand { careful, balanced, dynamic }

RiskBand bandForVolatility(double volatility) {
  if (volatility <= carefulMaxVolatility) return RiskBand.careful;
  if (volatility <= balancedMaxVolatility) return RiskBand.balanced;
  return RiskBand.dynamic;
}

int riskCoherence(double volatility, RiskBand profile) {
  final distance = (bandForVolatility(volatility).index - profile.index).abs();
  return switch (distance) {
    0 => 100,
    1 => 60,
    _ => 20,
  };
}

int riskPrudence(double drawdown, double acceptedLoss) {
  if (drawdown >= acceptedLoss) return 100;
  final extraPoints = (acceptedLoss - drawdown) * 100;
  return max(0, 100 - roundScore(extraPoints * pointsPerExtraLossPoint));
}

int riskProfileStars(int prudence, int coherence) {
  if (prudence >= threeStarsScore && coherence >= threeStarsScore) return 3;
  if ((prudence + coherence) / 2 >= twoStarsScore) return 2;
  return 1;
}

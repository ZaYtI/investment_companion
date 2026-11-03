import '../models/daily_challenge.dart';
import '../models/price_point.dart';
import 'calc/performance.dart';

const daysToWaitBeforeAfterwards = 30;

DailyScenario scenarioForToday(
  List<DailyScenario> scenarios, {
  required List<String> playedIds,
  required bool hasPlayedToday,
}) {
  if (hasPlayedToday && playedIds.isNotEmpty) {
    return scenarios.firstWhere((scenario) => scenario.id == playedIds.last);
  }
  final notPlayedYet = scenarios.where(
    (scenario) => !playedIds.contains(scenario.id),
  );
  if (notPlayedYet.isNotEmpty) return notPlayedYet.first;
  return scenarios[playedIds.length % scenarios.length];
}

class DayMove {
  final double dayChange;
  final double changeOneMonthLater;

  const DayMove({required this.dayChange, required this.changeOneMonthLater});
}

DayMove dayMoveOf(List<PricePoint> prices, DateTime date) {
  final index = prices.indexWhere((point) => point.date == date);
  final dayClose = prices[index].close;
  final laterDate = date.add(const Duration(days: daysToWaitBeforeAfterwards));
  final later = prices.firstWhere(
    (point) => !point.date.isBefore(laterDate),
    orElse: () => prices.last,
  );
  return DayMove(
    dayChange: variation(prices[index - 1].close, dayClose),
    changeOneMonthLater: variation(dayClose, later.close),
  );
}

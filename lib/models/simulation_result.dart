class KeyDateValue {
  final String label;
  final DateTime date;
  final double value;

  const KeyDateValue({
    required this.label,
    required this.date,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'date': date.toIso8601String(),
    'value': value,
  };
}

class SimulationResult {
  final List<DateTime> dates;
  final List<double> values;
  final List<double> invested;
  final double maxDrawdown;
  final double? volatility;
  final List<KeyDateValue> keyDates;

  const SimulationResult({
    required this.dates,
    required this.values,
    required this.invested,
    required this.maxDrawdown,
    required this.volatility,
    required this.keyDates,
  });

  double get finalValue => values.last;
  double get totalInvested => invested.last;
  double get gain => finalValue - totalInvested;
  double get performance => finalValue / totalInvested - 1;
  Duration get duration => dates.last.difference(dates.first);

  Map<String, dynamic> toJson() => {
    'dates': dates.map((date) => date.toIso8601String()).toList(),
    'values': values,
    'invested': invested,
    'maxDrawdown': maxDrawdown,
    'volatility': volatility,
    'keyDates': keyDates.map((keyDate) => keyDate.toJson()).toList(),
  };
}

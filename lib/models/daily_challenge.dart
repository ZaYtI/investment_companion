class DailyScenario {
  final String id;
  final DateTime date;
  final String seriesId;
  final String event;

  const DailyScenario({
    required this.id,
    required this.date,
    required this.seriesId,
    required this.event,
  });

  factory DailyScenario.fromJson(Map<String, dynamic> json) {
    return DailyScenario(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      seriesId: json['series'] as String,
      event: json['event'] as String,
    );
  }
}

class DailyChallengeContent {
  final double capital;
  final int timerSeconds;
  final String timeoutChoice;
  final List<Map<String, dynamic>> plans;
  final List<Map<String, dynamic>> choices;
  final List<DailyScenario> scenarios;

  const DailyChallengeContent({
    required this.capital,
    required this.timerSeconds,
    required this.timeoutChoice,
    required this.plans,
    required this.choices,
    required this.scenarios,
  });

  factory DailyChallengeContent.fromJson(Map<String, dynamic> json) {
    return DailyChallengeContent(
      capital: (json['capital'] as num).toDouble(),
      timerSeconds: json['timerSeconds'] as int,
      timeoutChoice: json['timeoutChoice'] as String,
      plans: (json['plans'] as List).cast<Map<String, dynamic>>(),
      choices: (json['choices'] as List).cast<Map<String, dynamic>>(),
      scenarios: (json['scenarios'] as List<dynamic>)
          .map((item) => DailyScenario.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SimulationExample {
  final String title;
  final String description;
  final DateTime start;
  final Map<String, int> percents;

  const SimulationExample({
    required this.title,
    required this.description,
    required this.start,
    required this.percents,
  });

  static final all = [
    SimulationExample(
      title: 'Tout sur le S&P 500 depuis le Covid',
      description: '100 % ETF S&P 500, placé juste avant la chute de 2020.',
      start: DateTime(2020, 3, 2),
      percents: const {'spy_weekly': 100},
    ),
    SimulationExample(
      title: 'Le classique 60/40 depuis Lehman',
      description: '60 % actions et 40 % obligations, en pleine crise de 2008.',
      start: DateTime(2008, 9, 15),
      percents: const {'spy_weekly': 60, 'bonds_weekly': 40},
    ),
    SimulationExample(
      title: 'Diversifié depuis la bulle internet',
      description: 'Actions, obligations et or, au sommet de mars 2000.',
      start: DateTime(2000, 3, 6),
      percents: const {'spy_weekly': 40, 'bonds_weekly': 40, 'gold_weekly': 20},
    ),
  ];
}

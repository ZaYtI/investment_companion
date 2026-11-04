class ProfilePortfolio {
  final String name;
  final String composition;
  final Map<String, int> percents;

  const ProfilePortfolio({
    required this.name,
    required this.composition,
    required this.percents,
  });

  static const all = [
    ProfilePortfolio(
      name: 'Prudent',
      composition: '70 % obligations, 20 % actions, 10 % or',
      percents: {'bonds_weekly': 70, 'spy_weekly': 20, 'gold_weekly': 10},
    ),
    ProfilePortfolio(
      name: 'Équilibré',
      composition: '60 % actions, 40 % obligations',
      percents: {'spy_weekly': 60, 'bonds_weekly': 40},
    ),
    ProfilePortfolio(
      name: 'Dynamique',
      composition: '70 % S&P 500, 30 % Nasdaq-100',
      percents: {'spy_weekly': 70, 'qqq_weekly': 30},
    ),
  ];
}

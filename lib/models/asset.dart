class Asset {
  final String id;
  final String name;
  final String category;

  const Asset({required this.id, required this.name, required this.category});

  static const all = [
    Asset(id: 'spy_weekly', name: 'ETF S&P 500', category: 'Actions'),
    Asset(id: 'world_weekly', name: 'ETF MSCI World', category: 'Actions'),
    Asset(id: 'qqq_weekly', name: 'Nasdaq-100', category: 'Technologie'),
    Asset(id: 'gold_weekly', name: 'Or', category: 'Matières'),
    Asset(
      id: 'bonds_weekly',
      name: "Obligations d'État",
      category: 'Obligations',
    ),
    Asset(id: 'btc_weekly', name: 'Bitcoin', category: 'Crypto'),
    Asset(id: 'cash', name: 'Liquidités', category: 'Sans risque'),
  ];

  static Asset byId(String id) => all.firstWhere((asset) => asset.id == id);
}

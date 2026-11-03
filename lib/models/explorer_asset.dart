class AssetCategory {
  final String id;
  final String name;
  final String subtitle;
  final int risk;
  final String explanation;

  const AssetCategory({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.risk,
    required this.explanation,
  });

  factory AssetCategory.fromJson(Map<String, dynamic> json) {
    return AssetCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String,
      risk: json['risk'] as int,
      explanation: json['explanation'] as String,
    );
  }
}

class ExplorerAsset {
  final String id;
  final String symbol;
  final String name;
  final String categoryId;
  final int risk;
  final String description;
  final String unit;
  final String? embeddedSeriesId;

  const ExplorerAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.categoryId,
    required this.risk,
    required this.description,
    required this.unit,
    this.embeddedSeriesId,
  });

  bool get isCurrencyPair => categoryId == 'currencies';

  factory ExplorerAsset.fromJson(Map<String, dynamic> json) {
    return ExplorerAsset(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      categoryId: json['category'] as String,
      risk: json['risk'] as int,
      description: json['description'] as String,
      unit: json['unit'] as String? ?? r'$',
      embeddedSeriesId: json['embeddedSeries'] as String?,
    );
  }
}

class AssetCatalog {
  final List<AssetCategory> categories;
  final List<ExplorerAsset> assets;

  const AssetCatalog({required this.categories, required this.assets});

  factory AssetCatalog.fromJson(Map<String, dynamic> json) {
    return AssetCatalog(
      categories: (json['categories'] as List<dynamic>)
          .map((item) => AssetCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
      assets: (json['assets'] as List<dynamic>)
          .map((item) => ExplorerAsset.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  AssetCategory categoryOf(ExplorerAsset asset) =>
      categories.firstWhere((category) => category.id == asset.categoryId);

  ExplorerAsset assetById(String id) =>
      assets.firstWhere((asset) => asset.id == id);
}

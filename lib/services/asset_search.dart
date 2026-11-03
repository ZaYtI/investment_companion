import '../models/explorer_asset.dart';

const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'ô': 'o',
  'ö': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
};

String normalizeForSearch(String text) {
  final lowerCase = text.toLowerCase();
  final buffer = StringBuffer();
  for (final character in lowerCase.split('')) {
    buffer.write(_accents[character] ?? character);
  }
  return buffer.toString().trim();
}

List<ExplorerAsset> filterAssets(
  List<ExplorerAsset> assets, {
  required String query,
  String? categoryId,
}) {
  final normalizedQuery = normalizeForSearch(query);
  return assets.where((asset) {
    final isInCategory = categoryId == null || asset.categoryId == categoryId;
    final matchesQuery =
        normalizeForSearch(asset.name).contains(normalizedQuery) ||
        normalizeForSearch(asset.symbol).contains(normalizedQuery);
    return isInCategory && matchesQuery;
  }).toList();
}

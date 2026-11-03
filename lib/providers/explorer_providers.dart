import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/favorites_repository.dart';
import '../models/explorer_asset.dart';
import '../models/price_series.dart';
import '../services/asset_search.dart';
import 'simulation_providers.dart';

final assetCatalogProvider = FutureProvider<AssetCatalog>((ref) async {
  final text = await rootBundle.loadString('assets/data/assets_catalog.json');
  return AssetCatalog.fromJson(jsonDecode(text) as Map<String, dynamic>);
});

class ExplorerFilter {
  final String query;
  final String? categoryId;

  const ExplorerFilter({this.query = '', this.categoryId});

  bool get isEmpty => query.trim().isEmpty && categoryId == null;
}

class ExplorerFilterNotifier extends Notifier<ExplorerFilter> {
  @override
  ExplorerFilter build() => const ExplorerFilter();

  void setQuery(String query) {
    state = ExplorerFilter(query: query, categoryId: state.categoryId);
  }

  void setCategory(String? categoryId) {
    state = ExplorerFilter(query: state.query, categoryId: categoryId);
  }
}

final explorerFilterProvider =
    NotifierProvider<ExplorerFilterNotifier, ExplorerFilter>(
      ExplorerFilterNotifier.new,
    );

final filteredAssetsProvider = Provider<AsyncValue<List<ExplorerAsset>>>((ref) {
  final filter = ref.watch(explorerFilterProvider);
  return ref
      .watch(assetCatalogProvider)
      .whenData(
        (catalog) => filterAssets(
          catalog.assets,
          query: filter.query,
          categoryId: filter.categoryId,
        ),
      );
});

final assetSeriesProvider = FutureProvider.family<PriceSeries, ExplorerAsset>((
  ref,
  asset,
) {
  final repository = ref.watch(priceRepositoryProvider);
  final embeddedSeriesId = asset.embeddedSeriesId;
  if (embeddedSeriesId != null) {
    return repository.getSeries(embeddedSeriesId);
  }
  return repository.getOnlineSeries(symbol: asset.symbol, name: asset.name);
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(),
);

class FavoritesNotifier extends AsyncNotifier<List<String>> {
  FavoritesRepository get _repository => ref.read(favoritesRepositoryProvider);

  @override
  Future<List<String>> build() => _repository.getAll();

  Future<void> toggle(String assetId) async {
    final favorites = await future;
    if (favorites.contains(assetId)) {
      await _repository.remove(assetId);
    } else {
      await _repository.add(assetId);
    }
    state = AsyncData(await _repository.getAll());
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<String>>(
      FavoritesNotifier.new,
    );

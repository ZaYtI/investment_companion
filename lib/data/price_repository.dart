import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/price_series.dart';

abstract class PriceRepository {
  Future<PriceSeries> getSeries(String id, {DateTime? from, DateTime? to});
}

class EmbeddedPriceRepository implements PriceRepository {
  final _loadedSeries = <String, PriceSeries>{};

  @override
  Future<PriceSeries> getSeries(
    String id, {
    DateTime? from,
    DateTime? to,
  }) async {
    final series = _loadedSeries[id] ?? await _load(id);
    _loadedSeries[id] = series;
    return series.between(from, to);
  }

  Future<PriceSeries> _load(String id) async {
    final text = await rootBundle.loadString('assets/data/series/$id.json');
    return PriceSeries.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }
}

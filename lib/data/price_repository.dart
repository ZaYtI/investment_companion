import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/price_point.dart';
import '../models/price_series.dart';
import '../services/calc/dca.dart';
import 'api/api_exceptions.dart';
import 'api/twelve_data_client.dart';
import 'price_cache.dart';

abstract class PriceRepository {
  bool get canCallApiNow;

  Future<PriceSeries> getSeries(String id, {DateTime? from, DateTime? to});

  Future<PriceSeries> getOnlineSeries({
    required String symbol,
    required String name,
  });

  Future<void> refreshFromApi();
}

class CachedPriceRepository implements PriceRepository {
  static const updatableSeriesIds = [
    'spy_weekly',
    'spy_monthly',
    'qqq_weekly',
    'gold_weekly',
    'world_weekly',
    'btc_weekly',
  ];
  static const refreshInterval = Duration(days: 1);
  static const onlineHistoryYears = 5;

  final PriceCache cache;
  final TwelveDataClient? client;
  final _loadedSeries = <String, PriceSeries>{};

  CachedPriceRepository({required this.cache, this.client});

  @override
  bool get canCallApiNow => client?.canCallNow ?? true;

  @override
  Future<PriceSeries> getSeries(
    String id, {
    DateTime? from,
    DateTime? to,
  }) async {
    final series = _loadedSeries[id] ??= await _load(id);
    return series.between(from, to);
  }

  @override
  Future<PriceSeries> getOnlineSeries({
    required String symbol,
    required String name,
  }) async {
    final cacheId = 'api:$symbol';
    var points = await cache.pointsOf(cacheId);
    final lastUpdate = await cache.lastUpdateOf(cacheId);
    final isRecent =
        lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < refreshInterval;
    final client = this.client;
    final mustWaitForQueue =
        points.isNotEmpty && client != null && !client.canCallNow;
    if (!isRecent && client != null && !mustWaitForQueue) {
      try {
        final now = DateTime.now();
        final start = points.isEmpty
            ? DateTime(now.year - onlineHistoryYears, now.month, now.day)
            : points.last.date;
        final newPoints = await client.timeSeries(
          symbol: symbol,
          interval: '1week',
          start: start,
        );
        await cache.save(cacheId, newPoints);
        points = _merge(points, newPoints);
      } on ApiException {
        if (points.isEmpty) rethrow;
      }
    }
    if (points.isEmpty) {
      throw const NoNetworkException();
    }
    return PriceSeries(
      id: cacheId,
      symbol: symbol,
      name: name,
      frequency: SeriesFrequency.weekly,
      points: points,
    );
  }

  @override
  Future<void> refreshFromApi() async {
    final client = this.client;
    if (client == null) return;
    for (final id in updatableSeriesIds) {
      try {
        await _refresh(client, id);
      } on ApiException {
        return;
      }
    }
  }

  Future<void> _refresh(TwelveDataClient client, String id) async {
    final lastUpdate = await cache.lastUpdateOf(id);
    final isRecent =
        lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < refreshInterval;
    if (isRecent) return;

    final series = await _load(id);
    final isMonthly = series.frequency == SeriesFrequency.monthly;
    var newPoints = await client.timeSeries(
      symbol: series.symbol,
      interval: isMonthly ? '1day' : '1week',
      start: series.lastDate,
    );
    if (isMonthly && newPoints.isNotEmpty) {
      newPoints = firstPriceOfEachMonth(
        newPoints,
        from: series.lastDate,
        to: newPoints.last.date,
      ).prices;
    }
    await cache.save(id, newPoints);
    _loadedSeries.remove(id);
  }

  Future<PriceSeries> _load(String id) async {
    final text = await rootBundle.loadString('assets/data/series/$id.json');
    final embedded = PriceSeries.fromJson(
      jsonDecode(text) as Map<String, dynamic>,
    );
    final cached = await cache.pointsOf(id);
    return embedded.withPoints(_merge(embedded.points, cached));
  }

  List<PricePoint> _merge(List<PricePoint> embedded, List<PricePoint> cached) {
    final closeByDate = {
      for (final point in embedded) point.date: point.close,
      for (final point in cached) point.date: point.close,
    };
    final dates = closeByDate.keys.toList()..sort();
    return [
      for (final date in dates)
        PricePoint(date: date, close: closeByDate[date]!),
    ];
  }
}

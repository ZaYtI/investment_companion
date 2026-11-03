import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config/env.dart';
import '../../models/price_point.dart';
import '../../models/symbol_match.dart';
import 'api_exceptions.dart';
import 'api_rate_limiter.dart';

class TwelveDataClient {
  static const _host = 'api.twelvedata.com';
  static const _timeout = Duration(seconds: 10);
  static const _quotaExceededCode = 429;
  static const _maxPoints = 5000;

  final http.Client _httpClient;
  final ApiRateLimiter rateLimiter;
  final String apiKey;

  TwelveDataClient({
    http.Client? httpClient,
    ApiRateLimiter? rateLimiter,
    this.apiKey = Env.twelveDataKey,
  }) : _httpClient = httpClient ?? http.Client(),
       rateLimiter = rateLimiter ?? ApiRateLimiter();

  bool get canCallNow => rateLimiter.canCallNow;

  Future<List<PricePoint>> timeSeries({
    required String symbol,
    required String interval,
    required DateTime start,
  }) async {
    final json = await _get('/time_series', {
      'symbol': symbol,
      'interval': interval,
      'start_date': _day(start),
      'order': 'ASC',
      'outputsize': '$_maxPoints',
    });
    if (json['status'] == 'error') {
      if (_isNoData(json)) return [];
      throw _errorFrom(json, symbol);
    }
    final values = json['values'];
    if (values is! List) throw const InvalidResponseException();
    return [
      for (final value in values.cast<Map<String, dynamic>>())
        PricePoint(
          date: DateTime.parse(value['datetime'] as String),
          close: double.parse(value['close'] as String),
        ),
    ];
  }

  Future<List<SymbolMatch>> searchSymbols(String query) async {
    final json = await _get('/symbol_search', {'symbol': query});
    if (json['status'] == 'error') throw _errorFrom(json, query);
    final data = json['data'];
    if (data is! List) throw const InvalidResponseException();
    return data.cast<Map<String, dynamic>>().map(SymbolMatch.fromJson).toList();
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> parameters,
  ) async {
    final uri = Uri.https(_host, path, {...parameters, 'apikey': apiKey});
    try {
      return await rateLimiter.schedule(() => _send(uri));
    } on QuotaExceededException {
      rateLimiter.markQuotaReached();
      return rateLimiter.schedule(() => _send(uri));
    }
  }

  Future<Map<String, dynamic>> _send(Uri uri) async {
    try {
      final response = await _httpClient.get(uri).timeout(_timeout);
      if (response.statusCode == _quotaExceededCode) {
        throw const QuotaExceededException();
      }
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const InvalidResponseException();
      }
      if (json['code'] == _quotaExceededCode) {
        throw const QuotaExceededException();
      }
      return json;
    } on TimeoutException {
      throw const NetworkTimeoutException();
    } on SocketException {
      throw const NoNetworkException();
    } on http.ClientException {
      throw const NoNetworkException();
    } on FormatException {
      throw const InvalidResponseException();
    }
  }

  bool _isNoData(Map<String, dynamic> json) =>
      (json['message'] as String? ?? '').startsWith('No data is available');

  ApiException _errorFrom(Map<String, dynamic> json, String symbol) {
    final code = json['code'];
    final message = json['message'] as String? ?? '';
    if (code == _quotaExceededCode) return const QuotaExceededException();
    if (message.contains('symbol')) return UnknownSymbolException(symbol);
    return const InvalidResponseException();
  }

  String _day(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

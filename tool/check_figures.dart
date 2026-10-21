import 'dart:convert';
import 'dart:io';

import 'src/figures.dart';
import 'src/series_transform.dart';

void main() {
  final spyWeekly = _load('spy_weekly');
  final qqqWeekly = _load('qqq_weekly');
  final goldWeekly = _load('gold_weekly');
  final bondsWeekly = _load('bonds_weekly');
  final worldWeekly = _load('world_weekly');
  final btcWeekly = _load('btc_weekly');
  final spyMonthly = _load('spy_monthly');
  final spyDaily2020 = _load('spy_daily_2020');

  _chapter1(spyWeekly, goldWeekly, worldWeekly);
  _chapter2(spyWeekly, goldWeekly, btcWeekly);
  _chapter3(spyWeekly);
  _chapter4(spyWeekly, spyMonthly);
  _chapter5(spyWeekly, qqqWeekly, bondsWeekly, goldWeekly);
  _chapter6(spyDaily2020);
  _chapter7(spyMonthly);
}

List<SeriesPoint> _load(String id) {
  final json = jsonDecode(
    File('assets/data/series/$id.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return [
    for (final point in (json['points'] as List).cast<Map<String, dynamic>>())
      SeriesPoint(
        DateTime.parse(point['date'] as String),
        (point['close'] as num).toDouble(),
      ),
  ];
}

String _pct(double value) =>
    '${value >= 0 ? '+' : ''}${(value * 100).toStringAsFixed(1)} %';

String _eur(double value) => '${value.round()} €';

String _day(SeriesPoint point) => formatDay(point.date);

int _monthsBetween(DateTime from, DateTime to) =>
    (to.year - from.year) * 12 + to.month - from.month;

void _title(String text) => stdout.writeln('\n## $text\n');

void _line(String text) => stdout.writeln('- $text');

void _chapter1(
  List<SeriesPoint> spy,
  List<SeriesPoint> gold,
  List<SeriesPoint> world,
) {
  _title('Chapitre 1 · Les bases (5 dernières années)');
  final from = DateTime(2021, 10, 11);
  for (final (name, series) in [
    ('ETF S&P 500', spy),
    ('Or', gold),
    ('ETF MSCI World', world),
  ]) {
    final start = closestOnOrAfter(series, from);
    _line(
      '$name : ${_day(start)} → ${_day(series.last)}, '
      '${_pct(change(start.close, series.last.close))}',
    );
  }
}

void _chapter2(
  List<SeriesPoint> spy,
  List<SeriesPoint> gold,
  List<SeriesPoint> btc,
) {
  _title('Chapitre 2 · Le risque (1 000 € par actif)');
  for (final year in [2018, 2019, 2020, 2022]) {
    stdout.writeln('\n**Départ $year**\n');
    for (final (name, series) in [
      ('Or', gold),
      ('ETF S&P 500', spy),
      ('Bitcoin', btc),
    ]) {
      final window = between(series, DateTime(year), series.last.date);
      final performance = change(window.first.close, window.last.close);
      _line(
        '$name : valeur finale ${_eur(1000 * (1 + performance))} '
        '(${_pct(performance)}), volatilité '
        '${_pct(annualizedWeeklyVolatility(window))}, pire baisse '
        '${_pct(maxDrawdown(window).percent)}',
      );
    }
  }
}

void _chapter3(List<SeriesPoint> spy) {
  _title('Chapitre 3 · Les baisses (2007 à 2013)');
  final crisis = between(spy, DateTime(2007), DateTime(2013, 12, 31));
  final drawdown = maxDrawdown(crisis, after: spy);
  _line(
    'Sommet ${_day(drawdown.peak)} (${drawdown.peak.close}), creux '
    '${_day(drawdown.trough)} (${drawdown.trough.close}) : '
    '${_pct(drawdown.percent)}, gain nécessaire '
    '${_pct(drawdown.requiredGain)}',
  );
  _line(
    'Durée de la descente : '
    '${_monthsBetween(drawdown.peak.date, drawdown.trough.date)} mois ; '
    'retour au sommet : ${drawdown.recovery == null ? '-' : _day(drawdown.recovery!)}',
  );
  for (final entry in [
    DateTime(2007, 10, 8),
    DateTime(2008, 1, 7),
    DateTime(2008, 9, 8),
  ]) {
    final start = closestOnOrAfter(spy, entry);
    final valueAtTrough = 10000 * drawdown.trough.close / start.close;
    final recovery = spy
        .where(
          (p) => p.date.isAfter(drawdown.trough.date) && p.close >= start.close,
        )
        .firstOrNull;
    _line(
      'Entrée ${_day(start)} : 10 000 € → ${_eur(valueAtTrough)} au creux '
      '(${_pct(valueAtTrough / 10000 - 1)}), gain nécessaire '
      '${_pct(10000 / valueAtTrough - 1)}, retour au niveau d\'entrée '
      '${recovery == null ? '-' : _day(recovery)}',
    );
  }
  final threeYearsLater = closestOnOrAfter(spy, DateTime(2012, 3, 5));
  _line(
    'Mars 2012 (${_day(threeYearsLater)}) : '
    '${(threeYearsLater.close / drawdown.trough.close).toStringAsFixed(2)} × '
    'le prix du creux',
  );
}

void _chapter4(List<SeriesPoint> spyWeekly, List<SeriesPoint> spyMonthly) {
  _title('Chapitre 4 · Investir chaque mois (2022)');
  final endOf2021 = spyWeekly.lastWhere((p) => p.date.year == 2021);
  final endOf2022 = spyWeekly.lastWhere((p) => p.date.year == 2022);
  _line('Année 2022 : ${_pct(change(endOf2021.close, endOf2022.close))}');
  for (var month = 4; month <= 9; month++) {
    final start = spyMonthly.firstWhere(
      (p) => p.date.year == 2022 && p.date.month == month,
    );
    final next = spyMonthly.firstWhere(
      (p) => p.date.year == 2022 && p.date.month == month + 1,
    );
    _line(
      'Mois ${month.toString().padLeft(2, '0')}/2022 : '
      '${_pct(change(start.close, next.close))}',
    );
  }
  final dca = monthlyInvestment(
    spyMonthly,
    amount: 100,
    from: DateTime(2022),
    to: spyMonthly.last.date,
    finalPrice: spyWeekly.last.close,
  );
  _line(
    '100 €/mois de janvier 2022 au ${formatDay(spyWeekly.last.date)} : '
    '${dca.deposits} versements, ${_eur(dca.invested)} → ${_eur(dca.value)} '
    '(${_pct(dca.performance)})',
  );
  final lumpSum =
      dca.invested *
      spyWeekly.last.close /
      spyMonthly.firstWhere((p) => p.date.year == 2022).close;
  _line('Même somme placée en janvier 2022 : ${_eur(lumpSum)}');
}

void _chapter5(
  List<SeriesPoint> spy,
  List<SeriesPoint> qqq,
  List<SeriesPoint> bonds,
  List<SeriesPoint> gold,
) {
  _title('Chapitre 5 · Diversifier (2000 à 2002)');
  final end = DateTime(2002, 10, 31);
  for (final (name, series) in [
    ('Nasdaq-100', qqq),
    ('S&P 500', spy),
    ('Obligations', bonds),
    ('Or', gold),
  ]) {
    final window = between(series, DateTime(2000, 3, 6), end);
    _line(
      '$name : ${_pct(change(window.first.close, window.last.close))}, '
      'pire baisse ${_pct(maxDrawdown(window).percent)}',
    );
  }
  final qqqPeak = maxDrawdown(between(qqq, DateTime(1999), end), after: qqq);
  _line(
    'Nasdaq-100 : sommet ${_day(qqqPeak.peak)}, retrouvé le '
    '${qqqPeak.recovery == null ? '-' : _day(qqqPeak.recovery!)}',
  );
  for (final entry in [DateTime(1999, 3, 8), DateTime(2000, 3, 6)]) {
    stdout.writeln('\n**Entrée ${formatDay(entry)}, 10 000 €**\n');
    for (final (name, weights) in [
      ('A · 100 % technologie', {qqq: 1.0}),
      ('B · 100 % S&P 500', {spy: 1.0}),
      (
        'C · 40 % S&P 500, 40 % obligations, 20 % or',
        {spy: 0.4, bonds: 0.4, gold: 0.2},
      ),
    ]) {
      final portfolio = buyAndHoldPortfolio(weights, from: entry, to: end);
      final drawdown = maxDrawdown(portfolio);
      _line(
        '$name : creux ${_eur(drawdown.trough.close)}, pire baisse '
        '${_pct(drawdown.percent)}, valeur finale ${_eur(portfolio.last.close)}',
      );
    }
  }
}

void _chapter6(List<SeriesPoint> daily) {
  _title('Chapitre 6 · Gérer une crise (12 mars 2020)');
  final crash = between(daily, DateTime(2020, 2, 19), DateTime(2020, 4, 30));
  final drawdown = maxDrawdown(crash);
  final sessions =
      crash.indexOf(drawdown.trough) - crash.indexOf(drawdown.peak);
  _line(
    'Sommet ${_day(drawdown.peak)} → creux ${_day(drawdown.trough)} : '
    '${_pct(drawdown.percent)} en $sessions séances',
  );
  for (final day in [
    DateTime(2020, 2, 24),
    DateTime(2020, 3, 9),
    DateTime(2020, 3, 12),
    DateTime(2020, 3, 16),
    DateTime(2020, 3, 23),
  ]) {
    final index = daily.indexWhere((p) => p.date == day);
    _line(
      '${formatDay(day)} : '
      '${_pct(change(daily[index - 1].close, daily[index].close))}',
    );
  }
  final march12 = daily.indexWhere((p) => p.date == DateTime(2020, 3, 12));
  _line(
    '10 000 € la veille → ${_eur(10000 * (1 + change(daily[march12 - 1].close, daily[march12].close)))} '
    'le 12 mars',
  );
  _line(
    '7 séances suivantes : '
    '${_pct(change(daily[march12].close, daily[march12 + 7].close))} '
    '(jusqu\'au ${_day(daily[march12 + 7])})',
  );
  _line(
    'Un an après (${_day(daily.last)}) : '
    '${_pct(change(daily[march12].close, daily.last.close))}',
  );
}

void _chapter7(List<SeriesPoint> monthly) {
  _title('Chapitre 7 · Test de résistance (versements depuis janvier 2008)');
  for (final amount in [129.0, 140.0]) {
    for (final years in [8, 10]) {
      final deposits = between(
        monthly,
        DateTime(2008),
        DateTime(2008 + years),
      ).take(years * 12).toList();
      var shares = 0.0;
      var worstRatio = double.infinity;
      SeriesPoint? worstPoint;
      for (final (index, point) in deposits.indexed) {
        shares += amount / point.close;
        final ratio = shares * point.close / (amount * (index + 1));
        if (ratio < worstRatio) {
          worstRatio = ratio;
          worstPoint = point;
        }
      }
      final finalPoint = closestOnOrAfter(monthly, DateTime(2008 + years));
      final value = shares * finalPoint.close;
      _line(
        '${amount.round()} €/mois pendant $years ans : '
        '${_eur(amount * deposits.length)} versés → ${_eur(value)} '
        '(${value >= 20000 ? 'objectif atteint' : 'objectif manqué'}), pire moment '
        '${_day(worstPoint!)} à ${_pct(worstRatio - 1)} des versements',
      );
    }
  }
}

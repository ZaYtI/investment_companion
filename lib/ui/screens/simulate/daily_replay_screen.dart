import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/price_point.dart';
import '../../../models/simulate_level.dart';
import '../../../providers/simulation_providers.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/skeleton_box.dart';
import '../../widgets/text/change_text.dart';
import 'simulator_scaffold.dart';
import 'simulator_widgets.dart';

class DailyReplayScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final SimulateLevel level;

  const DailyReplayScreen({
    super.key,
    required this.chapterNumber,
    required this.level,
  });

  @override
  ConsumerState<DailyReplayScreen> createState() => _DailyReplayScreenState();
}

class _DailyReplayScreenState extends ConsumerState<DailyReplayScreen> {
  late final _settings = widget.level.settings;
  late final double _capital = (_settings['capital'] as num).toDouble();
  late final Map<DateTime, String> _highlightedDays = {
    for (final day
        in (_settings['highlightedDays'] as List).cast<Map<String, dynamic>>())
      DateTime.parse(day['date'] as String): day['label'] as String,
  };
  late final List<Map<String, dynamic>> _jumps = (_settings['jumps'] as List)
      .cast<Map<String, dynamic>>();

  var _dayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final series = ref.watch(priceSeriesProvider(_settings['asset'] as String));
    return SimulatorScaffold(
      chapterNumber: widget.chapterNumber,
      title: 'Rejouer la crise',
      level: widget.level,
      children: [
        series.when(
          data: (series) => _buildReplay(series.points),
          loading: () => const SkeletonBox(height: 400),
          error: (_, _) =>
              const ErrorView(message: 'Impossible de charger les cours.'),
        ),
      ],
    );
  }

  Widget _buildReplay(List<PricePoint> days) {
    final textTheme = Theme.of(context).textTheme;
    final today = days[_dayIndex];
    final firstClose = days.first.close;
    final value = _capital * today.close / firstClose;
    final dailyChange = _dayIndex == 0
        ? 0.0
        : today.close / days[_dayIndex - 1].close - 1;
    final peakClose = days
        .sublist(0, _dayIndex + 1)
        .map((day) => day.close)
        .reduce((a, b) => a > b ? a : b);
    final dropFromPeak = today.close / peakClose - 1;
    final isLastDay = _dayIndex == days.length - 1;
    final visibleDays = days.sublist(0, _dayIndex + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppFormat.day(today.date),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_highlightedDays[today.date] != null)
                Text(
                  _highlightedDays[today.date]!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.goldText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 8),
              StatRow(
                label: 'Variation du jour',
                value: AppFormat.signedPercent(dailyChange),
                valueColor: ChangeText.colorFor(dailyChange),
              ),
              StatRow(
                label: 'Votre portefeuille',
                value: AppFormat.euro(value),
              ),
              StatRow(
                label: 'Baisse depuis le sommet',
                value: AppFormat.percent(dropFromPeak),
                valueColor: ChangeText.colorFor(dropFromPeak),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: isLastDay ? null : () => setState(() => _dayIndex++),
          child: const Text('Jour suivant'),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final jump in _jumps)
              OutlinedButton(
                onPressed: () => setState(
                  () => _dayIndex = days.indexWhere(
                    (day) => day.date == DateTime.parse(jump['date'] as String),
                  ),
                ),
                child: Text(jump['label'] as String),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (visibleDays.length > 1)
          ChartCard(
            title: 'Valeur de vos ${AppFormat.euro(_capital)}',
            trailing: '${visibleDays.length - 1} séances',
            lines: [
              ChartLine(
                isFilled: true,
                points: [
                  for (final day in visibleDays)
                    ChartPoint(day.date, _capital * day.close / firstClose),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

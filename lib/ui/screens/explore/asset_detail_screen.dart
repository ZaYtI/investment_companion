import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/asset.dart';
import '../../../models/explorer_asset.dart';
import '../../../models/price_series.dart';
import '../../../providers/explorer_providers.dart';
import '../../../providers/simulation_draft_provider.dart';
import '../../../providers/simulation_providers.dart';
import '../../../services/calc/risk.dart';
import '../../format/app_format.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/skeleton_box.dart';
import '../../widgets/text/change_text.dart';
import 'favorite_star.dart';
import 'queued_notice.dart';
import 'risk_dots.dart';

enum ChartPeriod {
  oneMonth('1M', '1 mois', 1),
  sixMonths('6M', '6 mois', 6),
  oneYear('1A', '1 an', 12),
  fiveYears('5A', '5 ans', 60);

  const ChartPeriod(this.label, this.description, this.months);

  final String label;
  final String description;
  final int months;
}

class AssetDetailScreen extends ConsumerStatefulWidget {
  final String assetId;

  const AssetDetailScreen({super.key, required this.assetId});

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  var _period = ChartPeriod.oneYear;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(assetCatalogProvider).value;
    if (catalog == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final asset = catalog.assetById(widget.assetId);
    final isFavorite =
        ref.watch(favoritesProvider).value?.contains(asset.id) ?? false;
    final series = ref.watch(assetSeriesProvider(asset));
    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          FavoriteStar(
            isFavorite: isFavorite,
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(asset.id),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            series.when(
              loading: () => ref.read(priceRepositoryProvider).canCallApiNow
                  ? const SkeletonBox(height: 360)
                  : const QueuedNotice(),
              error: (error, _) => ErrorView(
                message: '$error',
                onRetry: () => ref.invalidate(assetSeriesProvider(asset)),
              ),
              data: (series) => _AssetFigures(
                asset: asset,
                series: series,
                period: _period,
                onPeriodChanged: (period) => setState(() => _period = period),
              ),
            ),
            const SizedBox(height: 16),
            _AboutCard(asset: asset, category: catalog.categoryOf(asset)),
            if (_simulationAssetOf(asset) != null) ...[
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Simuler un placement',
                onPressed: () {
                  ref
                      .read(simulationDraftProvider.notifier)
                      .startWithAsset(_simulationAssetOf(asset)!);
                  context.go(AppRoutes.newSimulation);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _simulationAssetOf(ExplorerAsset asset) {
    final seriesId = asset.embeddedSeriesId;
    final isSimulable = Asset.all.any((simulable) => simulable.id == seriesId);
    return isSimulable ? seriesId : null;
  }
}

class _AssetFigures extends StatelessWidget {
  final ExplorerAsset asset;
  final PriceSeries series;
  final ChartPeriod period;
  final ValueChanged<ChartPeriod> onPeriodChanged;

  const _AssetFigures({
    required this.asset,
    required this.series,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lastDate = series.lastDate;
    final points = series.lastMonths(period.months).points;
    final closes = points.map((point) => point.close).toList();
    final hasEnoughPoints = closes.length >= 2;
    final performance = hasEnoughPoints ? closes.last / closes.first - 1 : 0.0;
    final returns = returnsFromPrices(closes);
    final volatility = returns.length >= minVolatilityPoints
        ? annualizedVolatility(returns)
        : null;
    final drawdown = hasEnoughPoints ? maxDrawdown(closes).percent : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              AppFormat.price(series.points.last.close, unit: asset.unit),
              style: textTheme.displaySmall,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: performance >= 0
                    ? AppColors.mintPale
                    : AppColors.coralPale,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${AppFormat.signedPercent(performance)} sur ${period.description}',
                style: textTheme.titleSmall?.copyWith(
                  color: ChangeText.colorFor(performance),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<ChartPeriod>(
                segments: [
                  for (final option in ChartPeriod.values)
                    ButtonSegment(value: option, label: Text(option.label)),
                ],
                selected: {period},
                showSelectedIcon: false,
                onSelectionChanged: (periods) => onPeriodChanged(periods.first),
              ),
              const SizedBox(height: 16),
              PriceChart(
                formatValue: (value) =>
                    AppFormat.price(value, unit: asset.unit),
                lines: [
                  ChartLine(
                    isFilled: true,
                    color: performance >= 0
                        ? AppColors.mintChart
                        : AppColors.red,
                    points: [
                      for (final point in points)
                        ChartPoint(point.date, point.close),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FigureTile(
                label: 'Performance',
                value: AppFormat.signedPercent(performance),
                color: ChangeText.colorFor(performance),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FigureTile(
                label: 'Volatilité',
                value: volatility == null
                    ? '—'
                    : '≈ ${AppFormat.percent(volatility)}',
                color: AppColors.assetBonds,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FigureTile(
                label: 'Pire baisse',
                value: AppFormat.percent(drawdown),
                color: ChangeText.colorFor(drawdown),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Que signifie ${AppFormat.signedPercent(performance)} ?',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Placer 100 € au début de la période donnerait environ '
                '${AppFormat.euro(100 * (1 + performance))} aujourd\'hui.',
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cours mis à jour le ${AppFormat.day(lastDate)}. Hors connexion, '
          'les derniers cours enregistrés restent visibles.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _FigureTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FigureTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final ExplorerAsset asset;
  final AssetCategory category;

  const _AboutCard({required this.asset, required this.category});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${asset.symbol} · ${category.name}',
            style: textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(asset.description, style: textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            category.explanation,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Échelle de risque', style: textTheme.bodyMedium),
              RiskDots(risk: asset.risk, showLabel: false),
              Text('${asset.risk} / ${RiskDots.maxRisk}'),
            ],
          ),
        ],
      ),
    );
  }
}

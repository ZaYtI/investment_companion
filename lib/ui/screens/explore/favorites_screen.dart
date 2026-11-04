import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/explorer_asset.dart';
import '../../../providers/explorer_providers.dart';
import '../../../providers/simulation_providers.dart';
import '../../format/app_format.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/states/empty_view.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/skeleton_box.dart';
import '../../widgets/text/change_text.dart';
import 'queued_notice.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogValue = ref.watch(assetCatalogProvider);
    final favoritesValue = ref.watch(favoritesProvider);
    final catalog = catalogValue.value;
    final favoriteIds = favoritesValue.value;
    final hasError = catalogValue.hasError || favoritesValue.hasError;
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: hasError
                  ? const Center(
                      child: ErrorView(
                        message: 'Impossible de charger vos favoris.',
                      ),
                    )
                  : catalog == null || favoriteIds == null
                  ? const Center(child: CircularProgressIndicator())
                  : favoriteIds.isEmpty
                  ? const Center(
                      child: EmptyView(
                        message:
                            "Aucun favori pour l'instant. Touchez l'étoile "
                            "d'une fiche actif pour la suivre ici.",
                        icon: Icons.star_outline,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(22),
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                          children: [
                            for (final id in favoriteIds)
                              _FavoriteCard(asset: catalog.assetById(id)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hors connexion, les derniers cours enregistrés '
                          'restent visibles.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: PrimaryButton(
                text: 'Ajouter un actif',
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  final ExplorerAsset asset;

  const _FavoriteCard({required this.asset});

  static const chartHeight = 60.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final seriesValue = ref.watch(assetSeriesProvider(asset));
    final series = seriesValue.value;
    final lastYear = series?.lastMonths(12);
    final performance = lastYear == null || lastYear.points.length < 2
        ? null
        : lastYear.points.last.close / lastYear.points.first.close - 1;
    return AppCard(
      onTap: () => context.push(AppRoutes.asset(asset.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            asset.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            'Sur 1 an',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (seriesValue.hasError)
            Text(
              'Cours indisponibles',
              style: textTheme.bodySmall?.copyWith(color: AppColors.redText),
            )
          else if (lastYear == null || performance == null)
            ref.read(priceRepositoryProvider).canCallApiNow
                ? const SkeletonBox(height: chartHeight)
                : const QueuedNotice(isCompact: true)
          else
            PriceChart(
              height: chartHeight,
              showDates: false,
              lines: [
                ChartLine(
                  color: performance >= 0 ? AppColors.mintChart : AppColors.red,
                  points: [
                    for (final point in lastYear.points)
                      ChartPoint(point.date, point.close),
                  ],
                ),
              ],
            ),
          const Spacer(),
          Text(
            performance == null ? '—' : AppFormat.signedPercent(performance),
            style: textTheme.headlineSmall?.copyWith(
              color: performance == null
                  ? AppColors.textSecondary
                  : ChangeText.colorFor(performance),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

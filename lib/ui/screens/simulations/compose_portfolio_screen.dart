import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/asset.dart';
import '../../../providers/simulation_draft_provider.dart';
import '../../../services/simulation_service.dart';
import '../../format/app_format.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/dashed_button.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/dialogs/app_bottom_sheet.dart';
import '../simulate/amount_card.dart';
import '../simulate/simulator_widgets.dart';
import 'step_label.dart';

class ComposePortfolioScreen extends ConsumerWidget {
  const ComposePortfolioScreen({super.key});

  Future<void> _addAsset(
    BuildContext context,
    WidgetRef ref,
    SimulationDraft draft,
  ) async {
    final availableAssets = Asset.all
        .where((asset) => !draft.percents.containsKey(asset.id))
        .toList();
    final picked = await showAppBottomSheet<Asset>(
      context,
      builder: (context) => _AssetPicker(assets: availableAssets),
    );
    if (picked != null) {
      ref.read(simulationDraftProvider.notifier).addAsset(picked.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final draft = ref.watch(simulationDraftProvider);
    final notifier = ref.read(simulationDraftProvider.notifier);
    final hasAssetsLeft = draft.percents.length < Asset.all.length;
    return Scaffold(
      appBar: AppBar(actions: const [StepLabel(step: 2)]),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Text(
                    'Composez votre portefeuille',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: const Icon(Icons.schedule, size: 18),
                      label: Text(
                        'Départ : ${AppFormat.monthYear(draft.start)}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<SimulationMode>(
                    segments: const [
                      ButtonSegment(
                        value: SimulationMode.lumpSum,
                        label: Text('Tout au départ'),
                      ),
                      ButtonSegment(
                        value: SimulationMode.monthly,
                        label: Text('Chaque mois'),
                      ),
                    ],
                    selected: {draft.mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (modes) =>
                        notifier.setMode(modes.first),
                  ),
                  const SizedBox(height: 12),
                  AmountCard(
                    key: ValueKey(draft.mode),
                    label: draft.isMonthly
                        ? 'Versement mensuel'
                        : 'Capital de départ',
                    value: draft.isMonthly
                        ? draft.monthlyAmount
                        : draft.capital,
                    min: draft.isMonthly
                        ? SimulationDraft.minMonthlyAmount
                        : SimulationDraft.minCapital,
                    max: draft.isMonthly
                        ? SimulationDraft.maxMonthlyAmount
                        : SimulationDraft.maxCapital,
                    step: draft.isMonthly
                        ? SimulationDraft.monthlyAmountStep
                        : SimulationDraft.capitalStep,
                    onChanged: notifier.setAmount,
                  ),
                  const SizedBox(height: 16),
                  _AllocationBar(
                    percents: draft.percents,
                    total: draft.totalPercent,
                  ),
                  const SizedBox(height: 12),
                  for (final assetId in draft.percents.keys) ...[
                    _AssetRow(
                      asset: Asset.byId(assetId),
                      percent: draft.percents[assetId]!,
                      amount: draft.amount * draft.percents[assetId]! / 100,
                      canIncrease: draft.totalPercent < 100,
                      onIncrease: () => notifier.increase(assetId),
                      onDecrease: () => notifier.decrease(assetId),
                      onRemove: () => notifier.removeAsset(assetId),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (hasAssetsLeft)
                    DashedActionButton(
                      label: 'Ajouter un actif',
                      icon: Icons.add,
                      onPressed: () => _addAsset(context, ref, draft),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total réparti',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: draft.isComplete
                              ? AppColors.mintPale
                              : AppColors.coralPale,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${draft.totalPercent} %',
                          style: textTheme.titleMedium?.copyWith(
                            color: draft.isComplete
                                ? AppColors.mintText
                                : AppColors.redText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!draft.isComplete)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Le total doit faire exactement 100 % pour lancer '
                        'la simulation.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.redText,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: PrimaryButton(
                text: 'Lancer la simulation',
                onPressed: draft.isComplete
                    ? () => context.push(AppRoutes.simulationResult)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetPicker extends StatelessWidget {
  final List<Asset> assets;

  const _AssetPicker({required this.assets});

  static const colorDotSize = 12.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(
        22,
        0,
        22,
        22 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Text('Ajouter un actif', style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Il arrive à 0 % : réglez ensuite sa part avec + et −.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        for (final asset in assets) ...[
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () => Navigator.of(context).pop(asset),
            child: Row(
              children: [
                Container(
                  width: colorDotSize,
                  height: colorDotSize,
                  decoration: BoxDecoration(
                    color: assetColors[asset.id],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        asset.category,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle, color: AppColors.mintText),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _AllocationBar extends StatelessWidget {
  final Map<String, int> percents;
  final int total;

  const _AllocationBar({required this.percents, required this.total});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 14,
        child: Row(
          children: [
            for (final entry in percents.entries)
              if (entry.value > 0)
                Expanded(
                  flex: entry.value,
                  child: Container(color: assetColors[entry.key]),
                ),
            if (total < 100)
              Expanded(
                flex: 100 - total,
                child: Container(color: AppColors.border),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  final Asset asset;
  final int percent;
  final double amount;
  final bool canIncrease;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _AssetRow({
    required this.asset,
    required this.percent,
    required this.amount,
    required this.canIncrease,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              color: assetColors[asset.id],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${asset.category} · ${AppFormat.euro(amount)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: percent > 0 ? onDecrease : null,
            icon: const Icon(Icons.remove),
            tooltip: 'Moins',
          ),
          SizedBox(
            width: 52,
            child: Text(
              '$percent %',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton.filledTonal(
            onPressed: canIncrease ? onIncrease : null,
            icon: const Icon(Icons.add),
            tooltip: 'Plus',
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Retirer',
          ),
        ],
      ),
    );
  }
}

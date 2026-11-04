import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/asset.dart';
import '../../../models/key_moment.dart';
import '../../../models/saved_simulation.dart';
import '../../../models/simulation_result.dart';
import '../../../providers/saved_simulations_provider.dart';
import '../../../providers/simulation_draft_provider.dart';
import '../../../providers/simulation_providers.dart';
import '../../../services/calc/portfolio.dart';
import '../../../services/calc/risk.dart';
import '../../../services/simulation_service.dart';
import '../../format/app_format.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/charts/price_chart.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/skeleton_box.dart';
import '../../widgets/text/change_text.dart';
import '../simulate/simulator_widgets.dart';
import 'name_dialog.dart';
import 'step_label.dart';

class SimulationResultScreen extends ConsumerWidget {
  const SimulationResultScreen({super.key});

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    SimulationDraft draft,
    SimulationResult result,
  ) async {
    final name = await showNameDialog(
      context,
      draft.name ?? 'Portefeuille ${AppFormat.monthYear(draft.start)}',
    );
    if (name == null) return;
    await ref
        .read(savedSimulationsProvider.notifier)
        .add(
          SavedSimulation(
            name: name,
            start: draft.start,
            mode: draft.mode,
            amount: draft.amount,
            weights: draft.weights,
            invested: result.totalInvested,
            finalValue: result.finalValue,
            createdAt: DateTime.now(),
          ),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('« $name » est enregistrée dans Mes simulations.'),
      ),
    );
    context.go(AppRoutes.simulations);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(simulationDraftProvider);
    final simulation = ref.watch(draftResultProvider);
    final result = simulation.value;
    final isSaved = draft.savedId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(draft.name ?? 'Résultat'),
        actions: [if (!isSaved) const StepLabel(step: 3)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  if (simulation.hasError)
                    _HistoryError(error: simulation.error!)
                  else if (result == null)
                    const SkeletonBox(height: 400)
                  else
                    _ResultContent(draft: draft, result: result),
                  const SizedBox(height: 20),
                  _OtherStartChips(draft: draft),
                  const SizedBox(height: 20),
                  Text(
                    'Prix bruts en dollars, sans frais ni dividendes. '
                    'Simulation pédagogique, pas un conseil financier.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    text: 'Modifier le portefeuille',
                    onPressed: () => context.go(AppRoutes.composeSimulation),
                  ),
                  if (!isSaved && result != null)
                    TextButton(
                      onPressed: () => _save(context, ref, draft, result),
                      child: const Text('Enregistrer dans Mes simulations'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final SimulationDraft draft;
  final SimulationResult result;

  const _ResultContent({required this.draft, required this.result});

  List<ChartMarker> _markers() {
    final events = <(DateTime, String, double)>[
      for (final keyDate in result.keyDates)
        (keyDate.date, keyDate.label, keyDate.value),
    ];
    final drawdown = maxDrawdown(result.values);
    if (drawdown.hasDrop) {
      events.add((
        result.dates[drawdown.troughIndex],
        'Creux du portefeuille',
        result.values[drawdown.troughIndex],
      ));
    }
    events.add((result.dates.last, "Aujourd'hui", result.finalValue));
    events.sort((a, b) => a.$1.compareTo(b.$1));
    return [
      for (final (index, (date, label, value)) in events.indexed)
        ChartMarker(
          date,
          index + 1,
          label: '${AppFormat.day(date)} · $label · ${AppFormat.euro(value)}',
        ),
    ];
  }

  String _durationText() {
    final months = (result.duration.inDays / 30.44).round();
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years == 0) return '$remainingMonths mois';
    if (remainingMonths == 0) return '$years ans';
    return '$years ans $remainingMonths mois';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMonthly = draft.mode == SimulationMode.monthly;
    final volatility = result.volatility;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Départ en ${AppFormat.monthYear(draft.start)}, '
          "jusqu'au ${AppFormat.day(result.dates.last)}",
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        ResultHeader(
          invested: result.totalInvested,
          finalValue: result.finalValue,
          investedLabel: isMonthly ? 'versés' : 'investis',
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: 'Valeur dans le temps',
          lines: [
            ChartLine(
              label: 'Valeur',
              isFilled: true,
              points: chartPointsOf(result.dates, result.values),
            ),
            if (isMonthly)
              ChartLine(
                label: 'Versé',
                color: AppColors.goldChart,
                isDashed: true,
                points: chartPointsOf(result.dates, result.invested),
              ),
          ],
          markers: _markers(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Tile(
                label: 'Pire baisse',
                value: AppFormat.percent(result.maxDrawdown),
                color: ChangeText.colorFor(result.maxDrawdown),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Tile(
                label: 'Volatilité',
                value: volatility == null ? '—' : AppFormat.percent(volatility),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Tile(label: 'Durée', value: _durationText()),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Tile({required this.label, required this.value, this.color});

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
            textAlign: TextAlign.center,
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

class _OtherStartChips extends ConsumerWidget {
  final SimulationDraft draft;

  const _OtherStartChips({required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final firstDates = {
      for (final assetId in draft.percents.keys)
        if (assetId != cashId && draft.percents[assetId]! > 0)
          assetId: ref.watch(priceSeriesProvider(assetId)).value?.firstDate,
    };
    final moments = [...KeyMoment.all]
      ..sort((a, b) => a.date.compareTo(b.date));
    String? missingAssetOf(KeyMoment moment) {
      for (final entry in firstDates.entries) {
        final firstDate = entry.value;
        if (firstDate != null && firstDate.isAfter(moment.date)) {
          return '${Asset.byId(entry.key).name} n\'a pas de données avant '
              '${AppFormat.monthYear(firstDate)}.';
        }
      }
      return null;
    }

    final explanations = {
      for (final moment in moments)
        if (missingAssetOf(moment) != null) missingAssetOf(moment)!,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MÊME PORTEFEUILLE, AUTRE DÉPART', style: textTheme.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final moment in moments)
              ChoiceChip(
                label: Text('${moment.date.year}'),
                selected: moment.date == draft.start,
                onSelected: missingAssetOf(moment) == null
                    ? (_) => ref
                          .read(simulationDraftProvider.notifier)
                          .setStart(moment.date)
                    : null,
              ),
          ],
        ),
        for (final explanation in explanations)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              explanation,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _HistoryError extends ConsumerWidget {
  final Object error;

  const _HistoryError({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = this.error;
    if (error is! HistoryTooShortException) {
      return ErrorView(message: simulationErrorMessage(error));
    }
    return Column(
      children: [
        ErrorView(
          message:
              '${Asset.byId(error.assetId).name} n\'a pas de données avant '
              '${AppFormat.monthYear(error.earliestDate)}.',
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          text: 'Commencer en ${AppFormat.monthYear(error.earliestDate)}',
          onPressed: () => ref
              .read(simulationDraftProvider.notifier)
              .setStart(error.earliestDate),
        ),
      ],
    );
  }
}

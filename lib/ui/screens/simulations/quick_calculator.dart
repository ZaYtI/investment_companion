import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/profile_portfolio.dart';
import '../../../models/simulation_result.dart';
import '../../../providers/simulation_draft_provider.dart';
import '../../../providers/simulation_providers.dart';
import '../../format/app_format.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/states/skeleton_box.dart';
import '../../widgets/text/animated_gain_counter.dart';
import '../simulate/amount_card.dart';
import '../simulate/simulations_builder.dart';
import '../simulate/simulator_widgets.dart';
import '../simulate/weights_editor.dart';

class QuickCalculator extends ConsumerStatefulWidget {
  const QuickCalculator({super.key});

  @override
  ConsumerState<QuickCalculator> createState() => _QuickCalculatorState();
}

class _QuickCalculatorState extends ConsumerState<QuickCalculator> {
  static const durations = [1, 5, 10];
  static const referenceSeries = 'spy_weekly';

  var _amount = SimulationDraft.defaultCapital;
  var _years = durations.last;

  void _openProfile(ProfilePortfolio profile, DateTime start) {
    ref
        .read(simulationDraftProvider.notifier)
        .openPortfolio(
          name: 'Profil ${profile.name.toLowerCase()}',
          start: start,
          percents: profile.percents,
          capital: _amount,
        );
    context.push(AppRoutes.simulationResult);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lastDate = ref
        .watch(priceSeriesProvider(referenceSeries))
        .value
        ?.lastDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Et si vous aviez investi ?', style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Choisissez un montant et une durée : voici ce qu\'il serait '
          'devenu selon votre profil.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        AmountCard(
          label: 'Montant',
          value: _amount,
          min: SimulationDraft.minCapital,
          max: SimulationDraft.maxCapital,
          step: SimulationDraft.capitalStep,
          onChanged: (amount) => setState(() => _amount = amount),
        ),
        const SizedBox(height: 12),
        OptionChips<int>(
          label: 'IL Y A',
          options: durations,
          selected: _years,
          labelOf: (years) => years == 1 ? '1 an' : '$years ans',
          onSelected: (years) => setState(() => _years = years),
        ),
        const SizedBox(height: 16),
        if (lastDate == null)
          const SkeletonBox(height: 240)
        else
          _buildProfiles(
            DateTime(lastDate.year - _years, lastDate.month, lastDate.day),
          ),
      ],
    );
  }

  Widget _buildProfiles(DateTime start) {
    return SimulationsBuilder(
      loadingHeight: 240,
      requests: [
        for (final profile in ProfilePortfolio.all)
          SimulationRequest(
            weights: weightsFromPercents(profile.percents),
            start: start,
            amount: _amount.toDouble(),
          ),
      ],
      builder: (results) => Column(
        children: [
          for (var i = 0; i < ProfilePortfolio.all.length; i++) ...[
            _ProfileResultCard(
              profile: ProfilePortfolio.all[i],
              result: results[i],
              onTap: () => _openProfile(ProfilePortfolio.all[i], start),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ProfileResultCard extends StatelessWidget {
  final ProfilePortfolio profile;
  final SimulationResult result;
  final VoidCallback onTap;

  const _ProfileResultCard({
    required this.profile,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  profile.composition,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedGainCounter.euro(
                  result.finalValue - result.totalInvested,
                  style: textTheme.headlineSmall,
                ),
                Text(
                  'soit ${AppFormat.euro(result.finalValue)} au total',
                  style: textTheme.bodyMedium,
                ),
                Text(
                  'Pire baisse en chemin : '
                  '${AppFormat.percent(result.maxDrawdown)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedGainCounter.percent(result.performance),
              const SizedBox(height: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

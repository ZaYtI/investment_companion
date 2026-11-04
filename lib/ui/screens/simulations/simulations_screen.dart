import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/saved_simulation.dart';
import '../../../models/simulation_example.dart';
import '../../../providers/saved_simulations_provider.dart';
import '../../../providers/simulation_draft_provider.dart';
import '../../../services/simulation_service.dart';
import '../../format/app_format.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badges/app_badge.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/selectable_card.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/loading_view.dart';
import '../../widgets/text/change_text.dart';

class SimulationsScreen extends ConsumerWidget {
  const SimulationsScreen({super.key});

  void _startNew(BuildContext context, WidgetRef ref) {
    ref.read(simulationDraftProvider.notifier).startNew();
    context.push(AppRoutes.newSimulation);
  }

  void _open(BuildContext context, WidgetRef ref, SavedSimulation simulation) {
    ref.read(simulationDraftProvider.notifier).open(simulation);
    context.push(AppRoutes.simulationResult);
  }

  void _openExample(
    BuildContext context,
    WidgetRef ref,
    SimulationExample example,
  ) {
    ref.read(simulationDraftProvider.notifier).openExample(example);
    context.push(AppRoutes.simulationResult);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulations = ref.watch(savedSimulationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes simulations')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: simulations.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(22),
                  child: LoadingView(),
                ),
                error: (_, _) => const Center(
                  child: ErrorView(
                    message: 'Impossible de charger vos simulations.',
                  ),
                ),
                data: (simulations) => simulations.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(22),
                        children: [
                          Text(
                            'Aucune simulation enregistrée',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ouvrez un exemple ci-dessous ou composez votre '
                            'propre portefeuille.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          _ExamplesSection(
                            onOpen: (example) =>
                                _openExample(context, ref, example),
                          ),
                        ],
                      )
                    : _SimulationList(
                        simulations: simulations,
                        onOpen: (simulation) => _open(context, ref, simulation),
                        onOpenExample: (example) =>
                            _openExample(context, ref, example),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: PrimaryButton(
                text: 'Nouvelle simulation',
                onPressed: () => _startNew(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulationList extends ConsumerWidget {
  final List<SavedSimulation> simulations;
  final ValueChanged<SavedSimulation> onOpen;
  final ValueChanged<SimulationExample> onOpenExample;

  const _SimulationList({
    required this.simulations,
    required this.onOpen,
    required this.onOpenExample,
  });

  Future<bool> _confirmDelete(
    BuildContext context,
    SavedSimulation simulation,
  ) {
    return showConfirmDialog(
      context,
      title: 'Supprimer « ${simulation.name} » ?',
      message: 'Cette simulation sera retirée de votre liste.',
      confirmLabel: 'Supprimer',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final totalInvested = simulations.fold(
      0.0,
      (sum, simulation) => sum + simulation.invested,
    );
    final totalValue = simulations.fold(
      0.0,
      (sum, simulation) => sum + simulation.finalValue,
    );
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Text(
          'Capital virtuel total',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          children: [
            Text(AppFormat.euro(totalValue), style: textTheme.displaySmall),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ChangeText.percent(totalValue / totalInvested - 1),
            ),
          ],
        ),
        Text(
          '${simulations.length} simulation${simulations.length > 1 ? 's' : ''}',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        for (final simulation in simulations) ...[
          Dismissible(
            key: ValueKey(simulation.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: AppColors.coralPale,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.redText),
            ),
            confirmDismiss: (_) => _confirmDelete(context, simulation),
            onDismissed: (_) => ref
                .read(savedSimulationsProvider.notifier)
                .remove(simulation.id!),
            child: SelectableCard(
              leading: const AppBadge.icon(
                Icons.show_chart,
                background: AppColors.mintPale,
                foreground: AppColors.mintText,
              ),
              title: simulation.name,
              subtitle:
                  'Départ ${AppFormat.monthYear(simulation.start)} · '
                  '${simulation.mode == SimulationMode.monthly ? '${AppFormat.euro(simulation.amount)} par mois' : '${simulation.weights.length} actif${simulation.weights.length > 1 ? 's' : ''}'}',
              trailing: ChangeText.percent(simulation.performance),
              onTap: () => onOpen(simulation),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Glissez une simulation vers la gauche pour la supprimer.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        _ExamplesSection(onOpen: onOpenExample),
      ],
    );
  }
}

class _ExamplesSection extends StatelessWidget {
  final ValueChanged<SimulationExample> onOpen;

  const _ExamplesSection({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('IDÉES DE SIMULATIONS', style: textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          '10 000 € placés à un moment clé : touchez pour voir le résultat.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        for (final example in SimulationExample.all) ...[
          SelectableCard(
            leading: AppBadge.text(
              '${example.start.year}',
              background: AppColors.mintPale,
              foreground: AppColors.mintText,
            ),
            title: example.title,
            subtitle: example.description,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onOpen(example),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

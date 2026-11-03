import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/key_moment.dart';
import '../../../providers/simulation_draft_provider.dart';
import '../../format/app_format.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badges/app_badge.dart';
import '../../widgets/buttons/dashed_button.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/selectable_card.dart';
import 'step_label.dart';

class NewSimulationDateScreen extends ConsumerWidget {
  const NewSimulationDateScreen({super.key});

  static final firstAvailableDate = DateTime(1999, 1, 4);

  Future<void> _pickOtherDate(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: firstAvailableDate,
      lastDate: DateTime.now(),
      helpText: 'Date de départ',
    );
    if (picked != null) {
      ref.read(simulationDraftProvider.notifier).setStart(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final start = ref.watch(simulationDraftProvider).start;
    final isKeyMoment = KeyMoment.all.any((moment) => moment.date == start);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle simulation'),
        actions: const [StepLabel(step: 1)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Text(
                    'Quand voulez-vous commencer ?',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choisissez un moment de l'histoire pour voir ce qu'un "
                    'portefeuille serait devenu.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Timeline(selected: start),
                  const SizedBox(height: 16),
                  for (final moment in KeyMoment.all) ...[
                    SelectableCard(
                      leading: AppBadge.text('${moment.date.year}'),
                      title: moment.title,
                      subtitle: moment.subtitle,
                      borderColor: moment.date == start ? AppColors.mint : null,
                      trailing: moment.date == start
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.mint,
                            )
                          : null,
                      onTap: () => ref
                          .read(simulationDraftProvider.notifier)
                          .setStart(moment.date),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!isKeyMoment) ...[
                    SelectableCard(
                      leading: AppBadge.text('${start.year}'),
                      title: 'Le ${AppFormat.day(start)}',
                      subtitle: 'Votre date',
                      borderColor: AppColors.mint,
                      trailing: const Icon(
                        Icons.check_circle,
                        color: AppColors.mint,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DashedActionButton(
                    label: 'Choisir une autre date',
                    icon: Icons.calendar_month_outlined,
                    alignment: Alignment.centerLeft,
                    onPressed: () => _pickOtherDate(context, ref, start),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: PrimaryButton(
                text: 'Continuer',
                onPressed: () => context.push(AppRoutes.composeSimulation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final DateTime selected;

  const _Timeline({required this.selected});

  static const firstYear = 1998;
  static const dotSize = 18.0;
  static const lineHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final moments = [...KeyMoment.all]
      ..sort((a, b) => a.date.compareTo(b.date));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Les grands moments depuis $firstYear',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: (dotSize - lineHeight) / 2,
                child: Container(height: lineHeight, color: AppColors.border),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final moment in moments)
                    _TimelineDot(
                      year: moment.date.year,
                      isSelected: moment.date == selected,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final int year;
  final bool isSelected;

  const _TimelineDot({required this.year, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: _Timeline.dotSize,
          height: _Timeline.dotSize,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.goldShadow : AppColors.mintChart,
              width: 3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$year',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

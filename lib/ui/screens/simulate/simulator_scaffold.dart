import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/level_type.dart';
import '../../../models/simulate_level.dart';
import '../../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import 'reading_question_card.dart';

class SimulatorScaffold extends ConsumerStatefulWidget {
  final int chapterNumber;
  final String title;
  final SimulateLevel level;
  final List<Widget> children;
  final String? priceDate;

  const SimulatorScaffold({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.level,
    required this.children,
    this.priceDate,
  });

  @override
  ConsumerState<SimulatorScaffold> createState() => _SimulatorScaffoldState();
}

class _SimulatorScaffoldState extends ConsumerState<SimulatorScaffold> {
  var _hasAnsweredQuestion = false;

  Future<void> _finish() async {
    await ref
        .read(progressProvider.notifier)
        .completeLevel(
          widget.chapterNumber,
          LevelType.simulate.index,
          xpEarned: LevelType.simulate.xp,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Niveau terminé · +${LevelType.simulate.xp} XP')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondaryStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Text(
                    widget.level.instruction,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...widget.children,
                  const SizedBox(height: 28),
                  ReadingQuestionCard(
                    question: widget.level.readingQuestion,
                    onAnswered: () =>
                        setState(() => _hasAnsweredQuestion = true),
                  ),
                  const SizedBox(height: 24),
                  for (final note in widget.level.notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(note, style: secondaryStyle),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: Column(
                children: [
                  Text(
                    [
                      if (widget.priceDate != null)
                        'Cours du ${widget.priceDate}',
                      'Simulation pédagogique, pas un conseil financier.',
                    ].join(' · '),
                    textAlign: TextAlign.center,
                    style: secondaryStyle,
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    text: 'Terminer le niveau · +${LevelType.simulate.xp} XP',
                    onPressed: _hasAnsweredQuestion ? _finish : null,
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

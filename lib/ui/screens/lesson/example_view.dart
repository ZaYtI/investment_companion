import 'package:flutter/material.dart';

import '../../../models/lesson_page.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import 'pip_says.dart';

class ExampleView extends StatelessWidget {
  final LessonPage page;

  const ExampleView({super.key, required this.page});

  static const stepDelay = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(page.title, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(page.text, style: textTheme.bodyLarge),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            children: [
              for (final (index, step) in page.steps.indexed)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: stepDelay * (index + 1),
                  curve: Interval(index / (index + 1), 1),
                  builder: (context, opacity, child) =>
                      Opacity(opacity: opacity, child: child),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.label,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          step.value,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (page.pip != null) ...[
          const SizedBox(height: 20),
          PipSays(text: page.pip!),
        ],
      ],
    );
  }
}

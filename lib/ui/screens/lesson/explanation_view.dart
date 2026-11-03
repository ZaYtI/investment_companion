import 'package:flutter/material.dart';

import '../../../models/glossary_term.dart';
import '../../../models/lesson_page.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import 'pip_says.dart';

class ExplanationView extends StatelessWidget {
  final LessonPage page;
  final Map<String, GlossaryTerm> glossary;

  const ExplanationView({
    super.key,
    required this.page,
    required this.glossary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final terms = page.terms
        .where((id) => glossary.containsKey(id))
        .map((id) => glossary[id]!)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(page.title, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(page.text, style: textTheme.bodyLarge),
        if (terms.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('À retenir', style: textTheme.labelMedium),
          const SizedBox(height: 8),
          for (final term in terms) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term.term,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    term.definition,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
        if (page.pip != null) ...[
          const SizedBox(height: 12),
          PipSays(text: page.pip!),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../models/lesson_page.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/selectable_card.dart';
import 'pip_says.dart';

class HookView extends StatefulWidget {
  final LessonPage page;

  const HookView({super.key, required this.page});

  @override
  State<HookView> createState() => _HookViewState();
}

class _HookViewState extends State<HookView> {
  int? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.page.title, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(widget.page.text, style: textTheme.bodyLarge),
        const SizedBox(height: 20),
        for (final (index, option) in widget.page.options.indexed) ...[
          SelectableCard(
            title: option,
            borderColor: _selectedOption == index ? AppColors.mint : null,
            onTap: () => setState(() => _selectedOption = index),
          ),
          const SizedBox(height: 12),
        ],
        if (widget.page.pip != null) ...[
          const SizedBox(height: 12),
          PipSays(text: widget.page.pip!),
        ],
      ],
    );
  }
}

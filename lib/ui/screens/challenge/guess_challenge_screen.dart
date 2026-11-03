import 'package:flutter/material.dart';

import '../../../models/challenge_level.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/selectable_card.dart';
import 'challenge_scaffold.dart';

class GuessChallengeScreen extends StatefulWidget {
  final int chapterNumber;
  final ChallengeLevel challenge;

  const GuessChallengeScreen({
    super.key,
    required this.chapterNumber,
    required this.challenge,
  });

  @override
  State<GuessChallengeScreen> createState() => _GuessChallengeScreenState();
}

class _GuessChallengeScreenState extends State<GuessChallengeScreen> {
  late final _data = widget.challenge.data;
  late final List<String> _choices = (_data['choices'] as List).cast<String>();
  late final int _answerIndex = _data['answerIndex'] as int;
  late final List<int> _starsByAttempt = (_data['starsByAttempt'] as List)
      .cast<int>();

  final _wrongChoices = <int>{};
  ChallengeResult? _result;

  void _answer(int index) {
    if (index != _answerIndex) {
      setState(() => _wrongChoices.add(index));
      return;
    }
    final attempt = _wrongChoices.length;
    setState(() {
      _result = ChallengeResult(
        stars: _starsByAttempt[attempt.clamp(0, _starsByAttempt.length - 1)],
        title: attempt == 0 ? 'Du premier coup !' : 'Trouvé !',
        explanation: _data['explanation'] as String,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChallengeScaffold(
      chapterNumber: widget.chapterNumber,
      situation: widget.challenge.situation,
      keyMessage: widget.challenge.keyMessage,
      result: _result,
      children: [
        for (final (index, choice) in _choices.indexed) ...[
          SelectableCard(
            title: choice,
            borderColor: _wrongChoices.contains(index)
                ? AppColors.redText
                : null,
            trailing: _wrongChoices.contains(index)
                ? const Icon(Icons.cancel, color: AppColors.redText)
                : null,
            onTap: _wrongChoices.contains(index) ? null : () => _answer(index),
          ),
          const SizedBox(height: 12),
        ],
        if (_wrongChoices.isNotEmpty)
          Text(
            'Pas tout à fait. Essayez encore.',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AppColors.redText),
          ),
      ],
    );
  }
}

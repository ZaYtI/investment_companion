import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/challenge_level.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/simulation_providers.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../simulate/simulator_widgets.dart';
import '../simulate/weights_editor.dart';
import 'challenge_scaffold.dart';

class PortfolioConstraintChallengeScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final ChallengeLevel challenge;

  const PortfolioConstraintChallengeScreen({
    super.key,
    required this.chapterNumber,
    required this.challenge,
  });

  @override
  ConsumerState<PortfolioConstraintChallengeScreen> createState() =>
      _PortfolioConstraintChallengeScreenState();
}

class _PortfolioConstraintChallengeScreenState
    extends ConsumerState<PortfolioConstraintChallengeScreen> {
  static const assets = [
    'qqq_weekly',
    'spy_weekly',
    'bonds_weekly',
    'gold_weekly',
  ];

  late final _data = widget.challenge.data;
  late final _period = _data['period'] as Map<String, dynamic>;
  late final double _maxDrawdown = (_data['maxDrawdown'] as num).toDouble();
  late final double _minEquityWeight = (_data['minEquityWeight'] as num)
      .toDouble();
  late final List<String> _equityAssets = (_data['equityAssets'] as List)
      .cast<String>();
  late final int _attempts = _data['attempts'] as int;
  late final List<int> _starsByAttempt = (_data['starsByAttempt'] as List)
      .cast<int>();

  var _percents = {for (final asset in assets) asset: 0};
  final _attemptMessages = <String>[];
  var _isRunning = false;
  ChallengeResult? _result;

  int get _totalPercent => totalPercent(_percents);

  Future<void> _validate() async {
    setState(() => _isRunning = true);
    final result = await ref
        .read(simulationServiceProvider)
        .simulate(
          weights: weightsFromPercents(_percents),
          start: DateTime.parse(_period['start'] as String),
          end: DateTime.parse(_period['end'] as String),
          amount: 10000,
        );
    final equityWeight =
        _equityAssets.fold(0, (sum, asset) => sum + _percents[asset]!) / 100;
    final isDrawdownOk = result.maxDrawdown >= _maxDrawdown;
    final isEquityOk = equityWeight >= _minEquityWeight;
    final attempt = _attemptMessages.length + 1;
    final message =
        'Essai $attempt : pire baisse ${AppFormat.percent(result.maxDrawdown)}, '
        '${AppFormat.percent(equityWeight)} en actions. '
        '${isDrawdownOk && isEquityOk
            ? 'Réussi !'
            : isEquityOk
            ? 'La baisse dépasse ${AppFormat.percent(-_maxDrawdown)}.'
            : 'Il faut au moins ${AppFormat.percent(_minEquityWeight)} en actions.'}';
    final isSuccess = isDrawdownOk && isEquityOk;
    if (isSuccess) {
      await ref.read(progressProvider.notifier).recordPortfolioChallengeWon();
    }
    setState(() {
      _isRunning = false;
      _attemptMessages.add(message);
      if (isSuccess || attempt == _attempts) {
        _result = ChallengeResult(
          stars: isSuccess ? _starsByAttempt[attempt - 1] : 1,
          title: isSuccess ? 'Portefeuille solide !' : 'Pas cette fois',
          explanation: _attemptMessages.join('\n'),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ChallengeScaffold(
      chapterNumber: widget.chapterNumber,
      situation: widget.challenge.situation,
      keyMessage: widget.challenge.keyMessage,
      result: _result,
      children: [
        Text(
          'Essai ${_attemptMessages.length + 1} sur $_attempts',
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        WeightsEditor(
          assetLabels: {for (final asset in assets) asset: assetLabels[asset]!},
          percents: _percents,
          onChanged: (percents) => setState(() => _percents = percents),
        ),
        const SizedBox(height: 12),
        for (final message in _attemptMessages)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.redText),
            ),
          ),
        const SizedBox(height: 12),
        PrimaryButton(
          text: 'Valider ce portefeuille',
          isLoading: _isRunning,
          onPressed: _totalPercent == 100 ? _validate : null,
        ),
      ],
    );
  }
}

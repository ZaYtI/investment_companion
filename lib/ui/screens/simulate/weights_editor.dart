import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';

class WeightsEditor extends StatelessWidget {
  final Map<String, String> assetLabels;
  final Map<String, int> percents;
  final ValueChanged<Map<String, int>> onChanged;

  const WeightsEditor({
    super.key,
    required this.assetLabels,
    required this.percents,
    required this.onChanged,
  });

  static const step = 10;

  int get total => percents.values.fold(0, (sum, percent) => sum + percent);

  void _change(String asset, int delta) {
    final newPercent = (percents[asset]! + delta).clamp(0, 100);
    onChanged({...percents, asset: newPercent});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isComplete = total == 100;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final asset in assetLabels.keys)
            Row(
              children: [
                Expanded(
                  child: Text(assetLabels[asset]!, style: textTheme.bodyLarge),
                ),
                IconButton(
                  onPressed: percents[asset]! > 0
                      ? () => _change(asset, -step)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Moins',
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '${percents[asset]} %',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: total < 100 ? () => _change(asset, step) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Plus',
                ),
              ],
            ),
          const Divider(),
          Text(
            isComplete
                ? 'Total : 100 %'
                : 'Total : $total %. Il doit faire exactement 100 %.',
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium?.copyWith(
              color: isComplete ? AppColors.mintText : AppColors.redText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../format/app_format.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';

String? validateAmount(
  String? text, {
  required int min,
  required int max,
  required String unit,
}) {
  if (text == null || text.trim().isEmpty) {
    return 'Indiquez une valeur.';
  }
  final amount = int.tryParse(text.trim());
  if (amount == null) {
    return 'Entrez un nombre entier.';
  }
  if (amount <= 0) {
    return 'La valeur doit être supérieure à 0.';
  }
  if (amount < min || amount > max) {
    return 'Choisissez entre ${AppFormat.number(min)} $unit '
        'et ${AppFormat.number(max)} $unit.';
  }
  return null;
}

class AmountCard extends StatefulWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String unit;
  final ValueChanged<int> onChanged;
  final ValueChanged<bool>? onValidityChanged;

  const AmountCard({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.onValidityChanged,
    this.unit = '€',
  });

  @override
  State<AmountCard> createState() => _AmountCardState();
}

class _AmountCardState extends State<AmountCard> {
  late final _controller = TextEditingController(text: '${widget.value}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? text) =>
      validateAmount(text, min: widget.min, max: widget.max, unit: widget.unit);

  void _onSliderChanged(double value) {
    final amount = value.round();
    setState(() => _controller.text = '$amount');
    widget.onValidityChanged?.call(true);
    widget.onChanged(amount);
  }

  void _onTyped(String text) {
    setState(() {});
    final isValid = _validate(text) == null;
    widget.onValidityChanged?.call(isValid);
    if (isValid) {
      widget.onChanged(int.parse(text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final error = _validate(_controller.text);
    final sliderValue = widget.value.clamp(widget.min, widget.max).toDouble();
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      suffixText: widget.unit,
                      border: InputBorder.none,
                      isDense: true,
                      errorStyle: const TextStyle(fontSize: 0, height: 0),
                    ),
                    validator: _validate,
                    onChanged: _onTyped,
                  ),
                ),
              ],
            ),
            if (error != null)
              Text(
                error,
                textAlign: TextAlign.end,
                style: textTheme.bodySmall?.copyWith(color: AppColors.redText),
              ),
            Slider(
              value: sliderValue,
              min: widget.min.toDouble(),
              max: widget.max.toDouble(),
              divisions: (widget.max - widget.min) ~/ widget.step,
              onChanged: _onSliderChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class InvalidAmountNotice extends StatelessWidget {
  final String message;

  const InvalidAmountNotice({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: AppColors.goldText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

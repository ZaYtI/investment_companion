import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  static const borderRadius = BorderRadius.all(Radius.circular(16));
  static const bottomEdgeHeight = 8.0;
  static const height = 56.0;
  static const fontSize = 17.0;
  static const loaderSize = 22.0;
  static const loaderStrokeWidth = 2.5;

  bool get isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          if (isEnabled)
            const BoxShadow(
              color: AppColors.goldShadow,
              offset: Offset(0, bottomEdgeHeight),
            ),
        ],
      ),
      child: IgnorePointer(
        ignoring: isLoading,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(height),
            shape: const RoundedRectangleBorder(borderRadius: borderRadius),
            textStyle: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontSize: fontSize, fontWeight: FontWeight.w700),
          ),
          child: isLoading
              ? const SizedBox.square(
                  dimension: loaderSize,
                  child: CircularProgressIndicator(
                    color: AppColors.goldShadow,
                    strokeWidth: loaderStrokeWidth,
                  ),
                )
              : Text(text),
        ),
      ),
    );
  }
}

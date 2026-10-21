import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PrimaryButton extends StatefulWidget {
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
  static const pressDuration = Duration(milliseconds: 90);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  final _states = WidgetStatesController();
  var _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;
  bool get _isSunken => _isEnabled && (_isPressed || widget.isLoading);

  @override
  void initState() {
    super.initState();
    _states.addListener(_onStatesChanged);
  }

  @override
  void dispose() {
    _states
      ..removeListener(_onStatesChanged)
      ..dispose();
    super.dispose();
  }

  void _onStatesChanged() {
    final isPressed = _states.value.contains(WidgetState.pressed);
    if (isPressed != _isPressed) setState(() => _isPressed = isPressed);
  }

  @override
  Widget build(BuildContext context) {
    final visibleEdge = _isSunken ? 0.0 : PrimaryButton.bottomEdgeHeight;
    return AnimatedContainer(
      duration: PrimaryButton.pressDuration,
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(
        0,
        PrimaryButton.bottomEdgeHeight - visibleEdge,
        0,
      ),
      decoration: BoxDecoration(
        borderRadius: PrimaryButton.borderRadius,
        boxShadow: [
          if (_isEnabled)
            BoxShadow(
              color: AppColors.goldShadow,
              offset: Offset(0, visibleEdge),
            ),
        ],
      ),
      child: IgnorePointer(
        ignoring: widget.isLoading,
        child: FilledButton(
          onPressed: widget.onPressed,
          statesController: _states,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(PrimaryButton.height),
            shape: const RoundedRectangleBorder(
              borderRadius: PrimaryButton.borderRadius,
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: PrimaryButton.fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: widget.isLoading
              ? const SizedBox.square(
                  dimension: PrimaryButton.loaderSize,
                  child: CircularProgressIndicator(
                    color: AppColors.goldShadow,
                    strokeWidth: PrimaryButton.loaderStrokeWidth,
                  ),
                )
              : Text(widget.text),
        ),
      ),
    );
  }
}

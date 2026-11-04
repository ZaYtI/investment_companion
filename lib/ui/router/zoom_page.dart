import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _zoomDuration = Duration(milliseconds: 380);
const _startScale = 0.85;

CustomTransitionPage<void> zoomPage({
  required GoRouterState state,
  required Widget child,
}) {
  final zoomOrigin = state.extra is Alignment
      ? state.extra! as Alignment
      : Alignment.center;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _zoomDuration,
    reverseTransitionDuration: _zoomDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          alignment: zoomOrigin,
          scale: Tween<double>(
            begin: _startScale,
            end: 1,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

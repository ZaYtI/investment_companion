import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class LoadingView extends StatelessWidget {
  final int itemCount;

  const LoadingView({super.key, this.itemCount = 3});

  static const itemHeight = 76.0;
  static const spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chargement',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            if (i > 0) const SizedBox(height: spacing),
            const SkeletonBox(height: itemHeight),
          ],
        ],
      ),
    );
  }
}

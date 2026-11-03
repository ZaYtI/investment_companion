import 'package:flutter/material.dart';

import '../../../models/level_type.dart';
import '../../widgets/states/empty_view.dart';

class LevelScreen extends StatelessWidget {
  final int chapterNumber;
  final int levelIndex;

  const LevelScreen({
    super.key,
    required this.chapterNumber,
    required this.levelIndex,
  });

  @override
  Widget build(BuildContext context) {
    final level = LevelType.values[levelIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Chapitre $chapterNumber · ${level.title}')),
      body: const Center(
        child: EmptyView(
          message: 'Ce niveau arrive à la prochaine étape.',
          icon: Icons.school_outlined,
        ),
      ),
    );
  }
}

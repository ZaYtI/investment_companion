import 'package:flutter/material.dart';

import '../../../data/chapters_data.dart';
import '../../../models/level_type.dart';
import '../../../models/simulate_level.dart';
import '../../widgets/states/empty_view.dart';
import '../../widgets/states/error_view.dart';
import 'dca_simulator_screen.dart';

class SimulateLevelScreen extends StatefulWidget {
  final int chapterNumber;

  const SimulateLevelScreen({super.key, required this.chapterNumber});

  @override
  State<SimulateLevelScreen> createState() => _SimulateLevelScreenState();
}

class _SimulateLevelScreenState extends State<SimulateLevelScreen> {
  late final Future<SimulateLevel> _level = loadSimulateLevel(
    widget.chapterNumber,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _level,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: ErrorView(message: 'Impossible de charger ce niveau.'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final level = snapshot.data!;
        return switch (level.simulator) {
          'dca' => DcaSimulatorScreen(
            chapterNumber: widget.chapterNumber,
            level: level,
          ),
          _ => Scaffold(
            appBar: AppBar(
              title: Text(
                'Chapitre ${widget.chapterNumber} · '
                '${LevelType.simulate.title}',
              ),
            ),
            body: const Center(
              child: EmptyView(
                message: 'Ce simulateur arrive bientôt.',
                icon: Icons.school_outlined,
              ),
            ),
          ),
        };
      },
    );
  }
}

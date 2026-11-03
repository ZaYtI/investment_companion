import 'package:flutter/material.dart';

import '../../../data/chapters_data.dart';
import '../../../models/simulate_level.dart';
import '../../widgets/states/empty_view.dart';
import '../../widgets/states/error_view.dart';
import 'daily_replay_screen.dart';
import 'dca_simulator_screen.dart';
import 'drawdown_timeline_screen.dart';
import 'goal_scenarios_screen.dart';
import 'portfolio_replay_screen.dart';
import 'risk_comparison_screen.dart';
import 'single_asset_simulator_screen.dart';

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
        final chapterNumber = widget.chapterNumber;
        return switch (level.simulator) {
          'singleAsset' => SingleAssetSimulatorScreen(
            chapterNumber: chapterNumber,
            level: level,
          ),
          'riskComparison' => RiskComparisonScreen(
            chapterNumber: chapterNumber,
            level: level,
          ),
          'drawdownTimeline' => DrawdownTimelineScreen(
            chapterNumber: chapterNumber,
            level: level,
          ),
          'dca' => DcaSimulatorScreen(
            chapterNumber: chapterNumber,
            level: level,
          ),
          'portfolioReplay' => PortfolioReplayScreen(
            chapterNumber: chapterNumber,
            level: level,
          ),
          'dailyReplay' => DailyReplayScreen(
            chapterNumber: chapterNumber,
            level: level,
          ),
          'goalScenarios' => GoalScenariosScreen(
            chapterNumber: chapterNumber,
            level: level,
          ),
          _ => Scaffold(
            appBar: AppBar(),
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

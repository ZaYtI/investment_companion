import 'package:flutter/material.dart';

import '../../../data/chapters_data.dart';
import '../../../models/challenge_level.dart';
import '../../widgets/states/empty_view.dart';
import '../../widgets/states/error_view.dart';
import 'decision_challenge_screen.dart';
import 'goal_plan_challenge_screen.dart';
import 'guess_challenge_screen.dart';
import 'monthly_plan_challenge_screen.dart';
import 'portfolio_constraint_challenge_screen.dart';
import 'risk_profile_challenge_screen.dart';

class ChallengeLevelScreen extends StatefulWidget {
  final int chapterNumber;

  const ChallengeLevelScreen({super.key, required this.chapterNumber});

  @override
  State<ChallengeLevelScreen> createState() => _ChallengeLevelScreenState();
}

class _ChallengeLevelScreenState extends State<ChallengeLevelScreen> {
  late final Future<ChallengeLevel> _challenge = loadChallengeLevel(
    widget.chapterNumber,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _challenge,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: ErrorView(message: 'Impossible de charger ce défi.'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final challenge = snapshot.data!;
        final chapterNumber = widget.chapterNumber;
        return switch (challenge.kind) {
          'guess' => GuessChallengeScreen(
            chapterNumber: chapterNumber,
            challenge: challenge,
          ),
          'riskProfile' => RiskProfileChallengeScreen(
            chapterNumber: chapterNumber,
            challenge: challenge,
          ),
          'decision' => DecisionChallengeScreen(
            chapterNumber: chapterNumber,
            challenge: challenge,
          ),
          'monthlyPlan' => MonthlyPlanChallengeScreen(
            chapterNumber: chapterNumber,
            challenge: challenge,
          ),
          'portfolioConstraint' => PortfolioConstraintChallengeScreen(
            chapterNumber: chapterNumber,
            challenge: challenge,
          ),
          'goalPlan' => GoalPlanChallengeScreen(
            chapterNumber: chapterNumber,
            challenge: challenge,
          ),
          _ => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: EmptyView(
                message: 'Ce défi arrive bientôt.',
                icon: Icons.emoji_events_outlined,
              ),
            ),
          ),
        };
      },
    );
  }
}

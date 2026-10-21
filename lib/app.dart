import 'package:flutter/material.dart';

import 'ui/theme/app_theme.dart';
import 'ui/widgets/buttons/dashed_button.dart';
import 'ui/widgets/buttons/primary_button.dart';

class InvestmentCompanionApp extends StatelessWidget {
  const InvestmentCompanionApp({super.key});

  static const title = 'Investment Companion';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DashedActionButton(
                  label: 'Choisir une autre date',
                  icon: Icons.calendar_today_outlined,
                  alignment: Alignment.centerLeft,
                  onPressed: () => debugPrint('Choisir une autre date'),
                ),
                const SizedBox(height: 16),
                DashedActionButton(
                  label: 'Ajouter un actif',
                  icon: Icons.add,
                  onPressed: () => debugPrint('Ajouter un actif'),
                ),
                const SizedBox(height: 16),
                const DashedActionButton(
                  label: 'Ajouter un actif',
                  icon: Icons.add,
                  onPressed: null,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Terminer le niveau · +60 XP',
                  onPressed: () => debugPrint('Bouton appuyé'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

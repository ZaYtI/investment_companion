import 'package:flutter/material.dart';

import 'ui/theme/app_theme.dart';
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
            child: PrimaryButton(
              text: 'Terminer le niveau · +60 XP',
              onPressed: () => debugPrint('Bouton appuyé'),
            ),
          ),
        ),
      ),
    );
  }
}

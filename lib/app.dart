import 'package:flutter/material.dart';

import 'ui/theme/app_theme.dart';

class InvestmentCompanionApp extends StatelessWidget {
  const InvestmentCompanionApp({super.key});

  static const title = 'Investment Companion';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(body: Center(child: Text(title))),
    );
  }
}

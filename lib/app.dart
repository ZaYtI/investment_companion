import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/theme/app_theme.dart';

class InvestmentCompanionApp extends StatelessWidget {
  final GoRouter router;

  const InvestmentCompanionApp({super.key, required this.router});

  static const title = 'Investment Companion';

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

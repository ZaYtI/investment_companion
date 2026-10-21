import 'package:flutter/material.dart';

class InvestmentCompanionApp extends StatelessWidget {
  const InvestmentCompanionApp({super.key});

  static const title = 'Investment Companion';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text(title))),
    );
  }
}

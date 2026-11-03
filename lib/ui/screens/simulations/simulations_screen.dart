import 'package:flutter/material.dart';

import '../../widgets/states/empty_view.dart';

class SimulationsScreen extends StatelessWidget {
  const SimulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes simulations')),
      body: const Center(
        child: EmptyView(
          message: 'Vos simulations apparaîtront ici.',
          icon: Icons.show_chart,
        ),
      ),
    );
  }
}

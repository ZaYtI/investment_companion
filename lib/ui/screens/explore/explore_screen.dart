import 'package:flutter/material.dart';

import '../../widgets/states/empty_view.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorer')),
      body: const Center(
        child: EmptyView(
          message: 'Le catalogue des actifs arrive bientôt.',
          icon: Icons.search,
        ),
      ),
    );
  }
}

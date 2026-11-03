import 'package:flutter/material.dart';

import '../../widgets/states/empty_view.dart';

class TrophiesScreen extends StatelessWidget {
  const TrophiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trophées')),
      body: const Center(
        child: EmptyView(
          message: 'Vos badges apparaîtront ici.',
          icon: Icons.emoji_events_outlined,
        ),
      ),
    );
  }
}

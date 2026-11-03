import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../widgets/states/empty_view.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte du temps')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmptyView(
              message: 'Les chapitres arrivent bientôt.',
              icon: Icons.map_outlined,
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.gallery),
              child: const Text('Ouvrir la galerie'),
            ),
          ],
        ),
      ),
    );
  }
}

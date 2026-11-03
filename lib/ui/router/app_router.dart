import 'package:go_router/go_router.dart';

import '../gallery/gallery_page.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/simulations/simulations_screen.dart';
import '../screens/trophies/trophies_screen.dart';
import '../shell/app_shell.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.map,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.map,
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.simulations,
              builder: (context, state) => const SimulationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.trophies,
              builder: (context, state) => const TrophiesScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.gallery,
      builder: (context, state) => const GalleryPage(),
    ),
  ],
);

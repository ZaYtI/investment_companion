import 'package:go_router/go_router.dart';

import '../gallery/gallery_page.dart';
import '../screens/challenge/challenge_level_screen.dart';
import '../screens/chapter/chapter_screen.dart';
import '../screens/context/context_screen.dart';
import '../screens/explore/asset_detail_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/explore/favorites_screen.dart';
import '../screens/explore/glossary_screen.dart';
import '../screens/lesson/lesson_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/simulate/simulate_level_screen.dart';
import '../screens/simulations/compose_portfolio_screen.dart';
import '../screens/simulations/new_simulation_date_screen.dart';
import '../screens/simulations/simulation_result_screen.dart';
import '../screens/simulations/simulations_screen.dart';
import '../screens/trophies/trophies_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../shell/app_shell.dart';
import 'app_routes.dart';

GoRouter createAppRouter({required bool showWelcome}) => GoRouter(
  initialLocation: showWelcome ? AppRoutes.welcome : AppRoutes.map,
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.map,
              builder: (context, state) => const MapScreen(),
              routes: [
                GoRoute(
                  path: 'chapitre/:number',
                  builder: (context, state) => ChapterScreen(
                    chapterNumber: int.parse(state.pathParameters['number']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'contexte',
                      builder: (context, state) => ContextScreen(
                        chapterNumber: int.parse(
                          state.pathParameters['number']!,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'niveau/:level',
                      builder: (context, state) {
                        final chapterNumber = int.parse(
                          state.pathParameters['number']!,
                        );
                        final levelIndex = int.parse(
                          state.pathParameters['level']!,
                        );
                        if (levelIndex == 0) {
                          return LessonScreen(chapterNumber: chapterNumber);
                        }
                        if (levelIndex == 1) {
                          return SimulateLevelScreen(
                            chapterNumber: chapterNumber,
                          );
                        }
                        return ChallengeLevelScreen(
                          chapterNumber: chapterNumber,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ExploreScreen(),
              routes: [
                GoRoute(
                  path: 'actif/:id',
                  builder: (context, state) =>
                      AssetDetailScreen(assetId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'favoris',
                  builder: (context, state) => const FavoritesScreen(),
                ),
                GoRoute(
                  path: 'glossaire',
                  builder: (context, state) => const GlossaryScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.simulations,
              builder: (context, state) => const SimulationsScreen(),
              routes: [
                GoRoute(
                  path: 'nouvelle',
                  builder: (context, state) => const NewSimulationDateScreen(),
                ),
                GoRoute(
                  path: 'portefeuille',
                  builder: (context, state) => const ComposePortfolioScreen(),
                ),
                GoRoute(
                  path: 'resultat',
                  builder: (context, state) => const SimulationResultScreen(),
                ),
              ],
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

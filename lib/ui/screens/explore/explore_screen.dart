import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/explorer_asset.dart';
import '../../../providers/explorer_providers.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badges/app_badge.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/selectable_card.dart';
import '../../widgets/states/empty_view.dart';
import '../../widgets/states/error_view.dart';
import '../../widgets/states/loading_view.dart';
import 'cube_icon.dart';
import 'risk_dots.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(assetCatalogProvider);
    final filter = ref.watch(explorerFilterProvider);
    final favoriteCount = ref.watch(favoritesProvider).value?.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.glossary),
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Glossaire',
          ),
        ],
      ),
      body: catalog.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(22), child: LoadingView()),
        error: (_, _) => const Center(
          child: ErrorView(message: 'Impossible de charger les actifs.'),
        ),
        data: (catalog) => ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const _SearchField(),
            const SizedBox(height: 12),
            SelectableCard(
              leading: const AppBadge.icon(
                Icons.star,
                background: AppColors.gold,
                foreground: AppColors.textPrimary,
              ),
              title: 'Mes favoris',
              subtitle:
                  '$favoriteCount actif${favoriteCount > 1 ? 's' : ''} '
                  'suivi${favoriteCount > 1 ? 's' : ''}',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.favorites),
            ),
            const SizedBox(height: 20),
            if (filter.isEmpty)
              _CategoryGrid(categories: catalog.categories)
            else
              _AssetResults(catalog: catalog, filter: filter),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final _controller = TextEditingController(
    text: ref.read(explorerFilterProvider).query,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(explorerFilterProvider.notifier).setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Rechercher un actif',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: _clear,
                icon: const Icon(Icons.close),
                tooltip: 'Effacer',
              ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      onChanged: (query) {
        setState(() {});
        ref.read(explorerFilterProvider.notifier).setQuery(query);
      },
    );
  }
}

class _CategoryGrid extends ConsumerWidget {
  final List<AssetCategory> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Familles d'actifs", style: textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            for (final category in categories)
              AppCard(
                onTap: () => ref
                    .read(explorerFilterProvider.notifier)
                    .setCategory(category.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CubeIcon(color: categoryColors[category.id]!),
                    const Spacer(),
                    Text(
                      category.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      category.subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RiskDots(risk: category.risk),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AssetResults extends ConsumerWidget {
  final AssetCatalog catalog;
  final ExplorerFilter filter;

  const _AssetResults({required this.catalog, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(filteredAssetsProvider).value ?? [];
    final notifier = ref.read(explorerFilterProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Toutes'),
              selected: filter.categoryId == null,
              onSelected: (_) => notifier.setCategory(null),
            ),
            for (final category in catalog.categories)
              ChoiceChip(
                label: Text(category.name),
                selected: filter.categoryId == category.id,
                onSelected: (_) => notifier.setCategory(category.id),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (assets.isEmpty)
          EmptyView(
            message: filter.query.trim().isEmpty
                ? 'Aucun actif dans cette famille.'
                : 'Aucun actif ne correspond à « ${filter.query.trim()} ».',
            icon: Icons.search_off,
          )
        else
          for (final asset in assets) ...[
            SelectableCard(
              title: asset.name,
              subtitle: '${asset.symbol} · ${catalog.categoryOf(asset).name}',
              trailing: RiskDots(risk: asset.risk, showLabel: false),
              onTap: () => context.push(AppRoutes.asset(asset.id)),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

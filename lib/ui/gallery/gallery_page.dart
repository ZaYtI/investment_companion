import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../format/app_format.dart';
import '../theme/app_colors.dart';
import '../widgets/badges/app_badge.dart';
import '../widgets/buttons/dashed_button.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/cards/app_card.dart';
import '../widgets/cards/selectable_card.dart';
import '../widgets/cards/stat_tile.dart';
import '../widgets/charts/price_chart.dart';
import '../widgets/navigation/app_navigation_bar.dart';
import '../widgets/progress/labeled_progress_bar.dart';
import '../widgets/states/empty_view.dart';
import '../widgets/states/error_view.dart';
import '../widgets/states/loading_view.dart';
import '../widgets/text/change_text.dart';

enum _Period { oneMonth, sixMonths, oneYear, fiveYears }

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const simulatedLoadingDuration = Duration(seconds: 2);
  static const sectionSpacing = 32.0;
  static const itemSpacing = 12.0;
  static const chartYears = [2000, 2008, 2020, 2022];

  var _isLoading = false;
  var _selectedYear = 2020;
  var _selectedChipYear = 2020;
  var _selectedPeriod = _Period.oneYear;
  var _selectedTab = AppTab.map;
  late final _chartData = _loadChartData();

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(simulatedLoadingDuration);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Galerie')),
      bottomNavigationBar: AppNavigationBar(
        selectedTab: _selectedTab,
        onTabSelected: (tab) => setState(() => _selectedTab = tab),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const _SectionTitle(
            'Bouton principal',
            description: 'Action principale de l\'écran, une seule par écran. S\'enfonce à l\'appui, grise quand elle est désactivée.',
          ),
          PrimaryButton(
            text: 'Terminer le niveau · +60 XP',
            onPressed: () => debugPrint('Bouton principal'),
          ),
          const SizedBox(height: itemSpacing),
          const PrimaryButton(text: 'Valider mon plan', onPressed: null),
          const SizedBox(height: itemSpacing),
          PrimaryButton(
            text: 'Appuyer pour charger 2 s',
            onPressed: _simulateLoading,
            isLoading: _isLoading,
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Bouton en pointillés',
            description: 'Action secondaire pour ajouter un élément ou faire un choix libre.',
          ),
          DashedActionButton(
            label: 'Choisir une autre date',
            icon: Icons.calendar_today_outlined,
            alignment: Alignment.centerLeft,
            onPressed: () => debugPrint('Choisir une autre date'),
          ),
          const SizedBox(height: itemSpacing),
          DashedActionButton(
            label: 'Ajouter un actif',
            icon: Icons.add,
            onPressed: () => debugPrint('Ajouter un actif'),
          ),
          const SizedBox(height: itemSpacing),
          const DashedActionButton(
            label: 'Ajouter un actif',
            icon: Icons.add,
            onPressed: null,
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Bouton texte',
            description: 'Action discrète, placée sous le bouton principal.',
          ),
          Center(
            child: TextButton(
              onPressed: () => debugPrint('Rejouer autrement'),
              child: const Text('Rejouer autrement'),
            ),
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Libellé',
            description: 'Petit titre doré au-dessus d\'un titre d\'écran.',
          ),
          Text('CHAPITRE 4 · 2022', style: textTheme.labelMedium),
          Text('Investir chaque mois', style: textTheme.headlineMedium),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Puces et segments',
            description: 'Choisir une option parmi quelques-unes, ou afficher des mots-clés.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final year in chartYears)
                ChoiceChip(
                  label: Text('$year'),
                  selected: year == _selectedChipYear,
                  onSelected: (_) => setState(() => _selectedChipYear = year),
                ),
            ],
          ),
          const SizedBox(height: itemSpacing),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Inflation')),
              Chip(label: Text('Taux directeurs')),
            ],
          ),
          const SizedBox(height: itemSpacing),
          SegmentedButton<_Period>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Period.oneMonth, label: Text('1M')),
              ButtonSegment(value: _Period.sixMonths, label: Text('6M')),
              ButtonSegment(value: _Period.oneYear, label: Text('1A')),
              ButtonSegment(value: _Period.fiveYears, label: Text('5A')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (selection) =>
                setState(() => _selectedPeriod = selection.single),
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Variations',
            description: 'Un gain ou une perte, toujours avec son signe : menthe si positif, rouge si négatif, gris si nul.',
          ),
          const Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              ChangeText.percent(0.312),
              ChangeText.percent(-0.12),
              ChangeText.percent(0),
              ChangeText.euro(1780),
              ChangeText.euro(-2300),
            ],
          ),
          const SizedBox(height: itemSpacing),
          Text(
            '${AppFormat.euro(5700)} investis deviennent '
            '${AppFormat.euro(7480)}',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Tuiles de statistique',
            description: 'Un libellé et une valeur dans une petite carte.',
          ),
          const Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Performance',
                  value: ChangeText.percent(0.18),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatTile(label: 'Volatilité', value: Text('≈ 16 %')),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  label: 'Pire baisse',
                  value: ChangeText.percent(-0.24),
                ),
              ),
            ],
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Barres de progression',
            description: 'Une mesure entre 0 et 1 avec son libellé et son pourcentage, par exemple le verdict d\'un défi.',
          ),
          const LabeledProgressBar(
            label: 'Cohérence avec votre plan',
            value: 0.9,
          ),
          const SizedBox(height: itemSpacing),
          const LabeledProgressBar(
            label: 'Prudence',
            value: 0.6,
            color: AppColors.goldChart,
          ),
          const SizedBox(height: itemSpacing),
          const LabeledProgressBar(label: 'Sang-froid', value: 0.85),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Pastilles',
            description: 'Petit carré coloré avec une lettre, une année ou une icône, souvent passé en leading d\'une carte.',
          ),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge.text(
                'A',
                background: AppColors.coralPale,
                foreground: AppColors.redText,
              ),
              AppBadge.text(
                'B',
                background: AppColors.mintPale,
                foreground: AppColors.mintText,
              ),
              AppBadge.text('2008'),
              AppBadge.icon(
                Icons.trending_up,
                background: AppColors.coralPale,
                foreground: AppColors.red,
              ),
              AppBadge.icon(
                Icons.star,
                background: AppColors.gold,
                foreground: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Cartes sélectionnables',
            description: 'Pastille, titre, sous-titre et élément de droite. Le contour se colore quand la carte est choisie ou mise en avant.',
          ),
          for (final (year, title, subtitle) in const [
            (2020, 'Mars 2020 · Covid', '−34 % en 23 séances'),
            (2008, 'Septembre 2008 · Lehman', "La crise financière s'accélère"),
            (
              2000,
              'Mars 2000 · Bulle internet',
              'Le sommet avant deux ans de baisse',
            ),
          ]) ...[
            SelectableCard(
              leading: year == _selectedYear
                  ? AppBadge.text(
                      '$year',
                      background: AppColors.mintPale,
                      foreground: AppColors.mintText,
                    )
                  : AppBadge.text('$year'),
              title: title,
              subtitle: subtitle,
              trailing: year == _selectedYear
                  ? const Icon(Icons.check_circle, color: AppColors.mint)
                  : const Icon(Icons.circle_outlined, color: AppColors.border),
              borderColor: year == _selectedYear ? AppColors.mint : null,
              onTap: () => setState(() => _selectedYear = year),
            ),
            const SizedBox(height: itemSpacing),
          ],
          SelectableCard(
            leading: const AppBadge.text(
              '1',
              background: AppColors.gold,
              foreground: AppColors.textPrimary,
            ),
            title: 'Comprendre',
            subtitle: 'Leçon · 4 min',
            trailing: const Icon(Icons.chevron_right),
            borderColor: AppColors.gold,
            onTap: () => debugPrint('Comprendre'),
          ),
          const SizedBox(height: itemSpacing),
          const SelectableCard(
            leading: AppBadge.icon(
              Icons.lock,
              foreground: AppColors.dashedBorder,
            ),
            title: 'Simuler',
            subtitle: 'Avec les vrais cours · +60 XP',
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Carte',
            description: 'Contenant blanc avec contour et tranche grise, pour n\'importe quel contenu.',
          ),
          const AppCard(
            child: Text('AppCard avec un contenu libre, non cliquable.'),
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Graphiques',
            description: 'Évolution dans le temps, avec marqueurs numérotés et ligne d\'objectif, sur les vraies séries de prix.',
          ),
          FutureBuilder(
            future: _chartData,
            builder: (context, snapshot) => switch (snapshot) {
              AsyncSnapshot(hasError: true) => const ErrorView(
                message: 'Impossible de lire les séries embarquées.',
              ),
              AsyncSnapshot(:final data?) => _ChartsSample(data),
              _ => const LoadingView(itemCount: 2),
            },
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'États',
            description: 'Ce qu\'affiche un écran de données pendant le chargement, en cas d\'erreur, ou quand il n\'y a rien.',
          ),
          const AppCard(child: LoadingView(itemCount: 2)),
          const SizedBox(height: itemSpacing),
          AppCard(
            child: ErrorView(
              message: 'Connexion impossible. Les cours affichés datent du 19 oct. 2026.',
              onRetry: () => debugPrint('Réessayer'),
            ),
          ),
          const SizedBox(height: itemSpacing),
          const AppCard(
            child: EmptyView(
              message: 'Aucune simulation pour l’instant. Créez la première.',
              icon: Icons.show_chart,
            ),
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Typographie',
            description: 'Les rôles de texte du thème : Sora pour les titres, DM Sans pour le reste.',
          ),
          const _TypographySample(),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle(
            'Couleurs',
            description: 'La palette de la charte. Appui long sur une couleur pour voir son nom.',
          ),
          const _PaletteSample(),
        ],
      ),
    );
  }
}

typedef _ChartData = ({List<ChartPoint> crash, List<ChartPoint> monthly});

Future<_ChartData> _loadChartData() async {
  Future<List<ChartPoint>> load(String id) async {
    final json = jsonDecode(
      await rootBundle.loadString('assets/data/series/$id.json'),
    ) as Map<String, dynamic>;
    return [
      for (final point in (json['points'] as List).cast<Map<String, dynamic>>())
        ChartPoint(
          DateTime.parse(point['date'] as String),
          (point['close'] as num).toDouble(),
        ),
    ];
  }

  return (
    crash: await load('spy_daily_2020'),
    monthly: await load('spy_monthly'),
  );
}

class _ChartsSample extends StatelessWidget {
  const _ChartsSample(this.data);

  final _ChartData data;

  static const monthlyDeposit = 100.0;
  static const capital = 10000.0;
  static const spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final start = data.crash.first.value;
    final portfolio = [
      for (final point in data.crash)
        ChartPoint(point.date, capital * point.value / start),
    ];
    final deposits = data.monthly
        .where((p) => !p.date.isBefore(DateTime(2022)))
        .toList();
    final value = <ChartPoint>[];
    final invested = <ChartPoint>[];
    var shares = 0.0;
    for (final (index, point) in deposits.indexed) {
      shares += monthlyDeposit / point.value;
      value.add(ChartPoint(point.date, shares * point.value));
      invested.add(ChartPoint(point.date, monthlyDeposit * (index + 1)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valeur dans le temps', style: textTheme.titleMedium),
              const SizedBox(height: spacing),
              PriceChart(
                lines: [ChartLine(points: portfolio, isFilled: true)],
                markers: [
                  ChartMarker(DateTime(2020, 3, 23), 1),
                  ChartMarker(DateTime(2020, 8, 3), 2),
                  ChartMarker(DateTime(2021, 3, 12), 3),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Capital investi et valeur', style: textTheme.titleMedium),
              const SizedBox(height: spacing),
              PriceChart(
                lines: [
                  ChartLine(points: value, isFilled: true),
                  ChartLine(
                    points: invested,
                    color: AppColors.goldChart,
                    isDashed: true,
                  ),
                ],
                target: 8000,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.description});

  final String text;
  final String description;

  static const spacing = 6.0;
  static const bottomSpacing = 16.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: textTheme.titleLarge),
          const SizedBox(height: spacing),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypographySample extends StatelessWidget {
  const _TypographySample();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style) in [
          ('headlineMedium · Sora', textTheme.headlineMedium),
          ('titleLarge · Sora', textTheme.titleLarge),
          ('titleMedium · DM Sans', textTheme.titleMedium),
          ('bodyLarge · DM Sans', textTheme.bodyLarge),
          ('bodyMedium · DM Sans', textTheme.bodyMedium),
          ('labelLarge · DM Sans', textTheme.labelLarge),
          ('LABELMEDIUM · LIBELLÉ DORÉ', textTheme.labelMedium),
        ])
          Text(name, style: style),
      ],
    );
  }
}

class _PaletteSample extends StatelessWidget {
  const _PaletteSample();

  static const swatchSize = 44.0;
  static const spacing = 8.0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final (name, color) in const [
          ('background', AppColors.background),
          ('surface', AppColors.surface),
          ('border', AppColors.border),
          ('dashedBorder', AppColors.dashedBorder),
          ('mapNight', AppColors.mapNight),
          ('mapNightLight', AppColors.mapNightLight),
          ('textPrimary', AppColors.textPrimary),
          ('textSecondary', AppColors.textSecondary),
          ('mint', AppColors.mint),
          ('mintChart', AppColors.mintChart),
          ('mintText', AppColors.mintText),
          ('mintPale', AppColors.mintPale),
          ('gold', AppColors.gold),
          ('goldShadow', AppColors.goldShadow),
          ('goldChart', AppColors.goldChart),
          ('goldText', AppColors.goldText),
          ('red', AppColors.red),
          ('redText', AppColors.redText),
          ('coralPale', AppColors.coralPale),
          ('assetStocks', AppColors.assetStocks),
          ('assetEtf', AppColors.assetEtf),
          ('assetBonds', AppColors.assetBonds),
          ('assetCrypto', AppColors.assetCrypto),
          (
            'assetCurrenciesAndChallenges',
            AppColors.assetCurrenciesAndChallenges,
          ),
        ])
          Tooltip(
            message: name,
            child: Container(
              width: swatchSize,
              height: swatchSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(spacing),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
      ],
    );
  }
}

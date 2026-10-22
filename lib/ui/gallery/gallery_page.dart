import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/buttons/dashed_button.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/cards/app_card.dart';
import '../widgets/cards/selectable_card.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const simulatedLoadingDuration = Duration(seconds: 2);
  static const sectionSpacing = 32.0;
  static const itemSpacing = 12.0;

  var _isLoading = false;
  var _selectedYear = 2020;

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(simulatedLoadingDuration);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galerie')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const _SectionTitle('Bouton principal'),
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
          const _SectionTitle('Bouton en pointillés'),
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
          const _SectionTitle('Bouton texte'),
          Center(
            child: TextButton(
              onPressed: () => debugPrint('Rejouer autrement'),
              child: const Text('Rejouer autrement'),
            ),
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle('Cartes sélectionnables'),
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
              leading: _Badge(
                '$year',
                year == _selectedYear
                    ? AppColors.mintPale
                    : AppColors.background,
                year == _selectedYear
                    ? AppColors.mintText
                    : AppColors.textPrimary,
              ),
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
            leading: const _Badge('A', AppColors.coralPale, AppColors.redText),
            title: 'Tout vendre',
            subtitle: "Je ne veux plus perdre d'argent",
            onTap: () => debugPrint('Tout vendre'),
          ),
          const SizedBox(height: itemSpacing),
          SelectableCard(
            leading: const _Badge('1', AppColors.gold, AppColors.textPrimary),
            title: 'Comprendre',
            subtitle: 'Leçon · 4 min',
            trailing: const Icon(Icons.chevron_right),
            borderColor: AppColors.gold,
            onTap: () => debugPrint('Comprendre'),
          ),
          const SizedBox(height: itemSpacing),
          const SelectableCard(
            leading: Icon(Icons.lock, color: AppColors.dashedBorder),
            title: 'Simuler',
            subtitle: 'Avec les vrais cours · +60 XP',
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle('Carte'),
          const AppCard(
            child: Text('AppCard avec un contenu libre, non cliquable.'),
          ),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle('Typographie'),
          const _TypographySample(),
          const SizedBox(height: sectionSpacing),
          const _SectionTitle('Couleurs'),
          const _PaletteSample(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  static const bottomSpacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: bottomSpacing),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.background, this.foreground);

  final String text;
  final Color background;
  final Color foreground;

  static const size = 44.0;
  static const radius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
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

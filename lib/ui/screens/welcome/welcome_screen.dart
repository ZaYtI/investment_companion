import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../data/app_preferences.dart';
import '../../../models/investor_profile.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/mascot/floating_pip.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const illustrationWidth = 215.0;
  static const illustrationHeight = 214.0;
  static const islandTop = 89.5;
  static const pipTop = 5.5;
  static const pipLeft = 77.0;

  var _selectedProfile = InvestorProfile.curious;
  var _isSaving = false;

  Future<void> _start() async {
    setState(() => _isSaving = true);
    await AppPreferences.saveWelcome(_selectedProfile);
    if (!mounted) return;
    context.go(AppRoutes.map);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.mapNight, AppColors.mapNightLight],
            ),
          ),
          child: Stack(
            children: [
              const _NightSky(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(
                                width: illustrationWidth,
                                height: illustrationHeight,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: islandTop,
                                      left: 0,
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/welcome_island.png',
                                        ),
                                        width: illustrationWidth,
                                      ),
                                    ),
                                    Positioned(
                                      top: pipTop,
                                      left: pipLeft,
                                      child: FloatingPip(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Remontez le temps pour apprendre à investir',
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: AppColors.surface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '10 000 € virtuels, de vraies données du passé. '
                                'Aucun compte bancaire, aucun risque.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.border,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Quel investisseur êtes-vous ?',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.surface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ProfileCard(
                                profile: InvestorProfile.curious,
                                icon: Icons.search,
                                iconColor: AppColors.mint,
                                isSelected:
                                    _selectedProfile == InvestorProfile.curious,
                                onTap: () => setState(
                                  () => _selectedProfile =
                                      InvestorProfile.curious,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ProfileCard(
                                profile: InvestorProfile.careful,
                                icon: Icons.shield_outlined,
                                iconColor: AppColors.assetBonds,
                                isSelected:
                                    _selectedProfile == InvestorProfile.careful,
                                onTap: () => setState(
                                  () => _selectedProfile =
                                      InvestorProfile.careful,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ProfileCard(
                                profile: InvestorProfile.ambitious,
                                icon: Icons.track_changes,
                                iconColor: AppColors.gold,
                                isSelected:
                                    _selectedProfile ==
                                    InvestorProfile.ambitious,
                                onTap: () => setState(
                                  () => _selectedProfile =
                                      InvestorProfile.ambitious,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: "C'est parti",
                        onPressed: _start,
                        isLoading: _isSaving,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NightSky extends StatelessWidget {
  const _NightSky();

  static const starPositions = [
    Alignment(-0.85, -0.83),
    Alignment(0.79, -0.74),
    Alignment(-0.54, -0.58),
    Alignment(0.64, -0.5),
    Alignment(-0.8, -0.29),
    Alignment(0.84, -0.22),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment(-0.64, -0.69),
          child: _Cloud(width: 110, height: 28),
        ),
        const Align(
          alignment: Alignment(0.69, -0.38),
          child: _Cloud(width: 95, height: 25),
        ),
        for (final position in starPositions)
          Align(alignment: position, child: const _Star()),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star();

  static const size = 3.0;
  static const opacity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width;
  final double height;

  const _Cloud({required this.width, required this.height});

  static const opacity = 0.07;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: opacity),
        borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final InvestorProfile profile;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.profile,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.mapNightLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.mint : AppColors.textSecondary,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mapNight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      profile.subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.border,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check, color: AppColors.mint),
            ],
          ),
        ),
      ),
    );
  }
}

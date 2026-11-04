import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/explorer_providers.dart';
import '../../../providers/simulation_providers.dart';
import '../../format/app_format.dart';
import '../../theme/app_colors.dart';

class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  var _isRetrying = false;

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    await ref.read(priceRepositoryProvider).refreshFromApi(force: true);
    ref.invalidate(priceSeriesProvider);
    ref.invalidate(assetSeriesProvider);
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectionStatusProvider);
    if (isOnline) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final lastUpdate = ref.watch(lastPriceUpdateProvider).value;
    final lastUpdateText = lastUpdate == null
        ? 'cours embarqués'
        : 'cours du ${AppFormat.day(lastUpdate)} à '
              '${lastUpdate.hour.toString().padLeft(2, '0')}:'
              '${lastUpdate.minute.toString().padLeft(2, '0')}';
    return Material(
      color: AppColors.mapNight,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        child: Row(
          children: [
            const Icon(Icons.wifi_off, color: AppColors.gold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Hors connexion · $lastUpdateText',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: AppColors.surface),
              ),
            ),
            TextButton(
              onPressed: _isRetrying ? null : _retry,
              child: Text(
                _isRetrying ? 'Connexion…' : 'Réessayer',
                style: const TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

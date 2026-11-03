import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class FavoriteStar extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteStar({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  State<FavoriteStar> createState() => _FavoriteStarState();
}

class _FavoriteStarState extends State<FavoriteStar> {
  static const poppedScale = 1.4;
  static const popDuration = Duration(milliseconds: 150);

  var _isPopped = false;

  void _onPressed() {
    setState(() => _isPopped = true);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _onPressed,
      tooltip: widget.isFavorite
          ? 'Retirer des favoris'
          : 'Ajouter aux favoris',
      icon: AnimatedScale(
        scale: _isPopped ? poppedScale : 1,
        duration: popDuration,
        curve: Curves.easeOut,
        onEnd: () {
          if (_isPopped) setState(() => _isPopped = false);
        },
        child: Icon(
          widget.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: widget.isFavorite ? AppColors.gold : AppColors.textSecondary,
          size: 32,
        ),
      ),
    );
  }
}

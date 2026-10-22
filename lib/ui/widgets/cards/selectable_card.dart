import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_card.dart';

class SelectableCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SelectableCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.borderColor,
    this.onTap,
  });

  static const leadingSpacing = 14.0;
  static const trailingSpacing = 12.0;
  static const titleFontSize = 18.0;
  static const subtitleFontSize = 15.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      borderColor: borderColor,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: leadingSpacing),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: subtitleFontSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: trailingSpacing),
            trailing!,
          ],
        ],
      ),
    );
  }
}

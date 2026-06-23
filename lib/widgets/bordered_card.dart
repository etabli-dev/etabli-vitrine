import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';

/// A flat, border-defined container — the core surface primitive for the
/// "borders over shadows" aesthetic. Optional [onTap] makes it interactive.
class BorderedCard extends StatelessWidget {
  const BorderedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(VitrineTokens.space4),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = VitrineColors.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(VitrineTokens.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VitrineTokens.radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VitrineTokens.radius),
            border: Border.all(
              color: colors.border,
              width: VitrineTokens.borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

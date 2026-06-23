// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../theme/coder_theme_vitrine.dart';
import '../theme/coder_theme_vitrine_tokens.dart';

/// A small uppercase monospaced tag — used for source-type / status chips.
class MonoTag extends StatelessWidget {
  const MonoTag(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = VitrineColors.of(context);
    final c = color ?? colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VitrineTokens.space2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VitrineTokens.radius),
        border: Border.all(color: c, width: VitrineTokens.borderWidth),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: VitrineTokens.monoFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: c,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Design system spacing tokens for Clube de Leitura D'Elas.
///
/// Scale based on powers of two and 4pt/8pt grid steps (2px to 64px).
@immutable
class AppSpacingTokens extends ThemeExtension<AppSpacingTokens> {
  const AppSpacingTokens({
    required this.s2,
    required this.s4,
    required this.s8,
    required this.s12,
    required this.s16,
    required this.s24,
    required this.s32,
    required this.s40,
    required this.s48,
    required this.s64,
  });

  final double s2;
  final double s4;
  final double s8;
  final double s12;
  final double s16;
  final double s24;
  final double s32;
  final double s40;
  final double s48;
  final double s64;

  /// Standard spacing tokens based on Figma specs (up to 64).
  static const standard = AppSpacingTokens(
    s2: 2.0,
    s4: 4.0,
    s8: 8.0,
    s12: 12.0,
    s16: 16.0,
    s24: 24.0,
    s32: 32.0,
    s40: 40.0,
    s48: 48.0,
    s64: 64.0,
  );

  /// Helper getter to retrieve spacing tokens directly from BuildContext.
  static AppSpacingTokens of(BuildContext context) {
    return Theme.of(context).extension<AppSpacingTokens>() ??
        AppSpacingTokens.standard;
  }

  @override
  AppSpacingTokens copyWith({
    double? s2,
    double? s4,
    double? s8,
    double? s12,
    double? s16,
    double? s24,
    double? s32,
    double? s40,
    double? s48,
    double? s64,
  }) {
    return AppSpacingTokens(
      s2: s2 ?? this.s2,
      s4: s4 ?? this.s4,
      s8: s8 ?? this.s8,
      s12: s12 ?? this.s12,
      s16: s16 ?? this.s16,
      s24: s24 ?? this.s24,
      s32: s32 ?? this.s32,
      s40: s40 ?? this.s40,
      s48: s48 ?? this.s48,
      s64: s64 ?? this.s64,
    );
  }

  @override
  AppSpacingTokens lerp(ThemeExtension<AppSpacingTokens>? other, double t) {
    if (other is! AppSpacingTokens) {
      return this;
    }
    return AppSpacingTokens(
      s2: _lerpDouble(s2, other.s2, t),
      s4: _lerpDouble(s4, other.s4, t),
      s8: _lerpDouble(s8, other.s8, t),
      s12: _lerpDouble(s12, other.s12, t),
      s16: _lerpDouble(s16, other.s16, t),
      s24: _lerpDouble(s24, other.s24, t),
      s32: _lerpDouble(s32, other.s32, t),
      s40: _lerpDouble(s40, other.s40, t),
      s48: _lerpDouble(s48, other.s48, t),
      s64: _lerpDouble(s64, other.s64, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSpacingTokens &&
        other.s2 == s2 &&
        other.s4 == s4 &&
        other.s8 == s8 &&
        other.s12 == s12 &&
        other.s16 == s16 &&
        other.s24 == s24 &&
        other.s32 == s32 &&
        other.s40 == s40 &&
        other.s48 == s48 &&
        other.s64 == s64;
  }

  @override
  int get hashCode => Object.hashAll([
        s2,
        s4,
        s8,
        s12,
        s16,
        s24,
        s32,
        s40,
        s48,
        s64,
      ]);
}

/// Extension on BuildContext for quick access to spacing tokens via `context.spacing`.
extension AppSpacingExtension on BuildContext {
  AppSpacingTokens get spacing => AppSpacingTokens.of(this);
}

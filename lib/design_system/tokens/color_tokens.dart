import 'package:flutter/material.dart';

/// Design system color tokens for Clube de Leitura D'Elas.
///
/// Contains 33 semantic tokens for background, surface, border, text,
/// overlay, action, and feedback elements in both Light and Dark modes.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.bgDefault,
    required this.bgSubtle,
    required this.surfaceDefault,
    required this.surfaceSunken,
    required this.surfaceBrandSoft,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderBrand,
    required this.textDefault,
    required this.textMuted,
    required this.textInverse,
    required this.textBrand,
    required this.textOnBrand,
    required this.overlayScrim,
    required this.actionPrimary,
    required this.actionPrimaryHover,
    required this.actionPrimaryPressed,
    required this.actionDanger,
    required this.actionDisabledBg,
    required this.actionDisabledFg,
    required this.actionFocusRing,
    required this.feedbackSuccess,
    required this.feedbackSuccessLight,
    required this.feedbackSuccessDark,
    required this.feedbackWarning,
    required this.feedbackWarningLight,
    required this.feedbackWarningDark,
    required this.feedbackError,
    required this.feedbackErrorLight,
    required this.feedbackErrorDark,
    required this.feedbackInfo,
    required this.feedbackInfoLight,
    required this.feedbackInfoDark,
  });

  // --- Background ---
  final Color bgDefault;
  final Color bgSubtle;

  // --- Surface ---
  final Color surfaceDefault;
  final Color surfaceSunken;
  final Color surfaceBrandSoft;

  // --- Border ---
  final Color borderDefault;
  final Color borderStrong;
  final Color borderBrand;

  // --- Text & Overlay ---
  final Color textDefault;
  final Color textMuted;
  final Color textInverse;
  final Color textBrand;
  final Color textOnBrand;
  final Color overlayScrim;

  // --- Action ---
  final Color actionPrimary;
  final Color actionPrimaryHover;
  final Color actionPrimaryPressed;
  final Color actionDanger;
  final Color actionDisabledBg;
  final Color actionDisabledFg;
  final Color actionFocusRing;

  // --- Feedback ---
  final Color feedbackSuccess;
  final Color feedbackSuccessLight;
  final Color feedbackSuccessDark;
  final Color feedbackWarning;
  final Color feedbackWarningLight;
  final Color feedbackWarningDark;
  final Color feedbackError;
  final Color feedbackErrorLight;
  final Color feedbackErrorDark;
  final Color feedbackInfo;
  final Color feedbackInfoLight;
  final Color feedbackInfoDark;

  /// Light theme color tokens based on Figma specs.
  static const light = AppColorTokens(
    bgDefault: Color(0xFFFFFFFF),
    bgSubtle: Color(0xFFFAF8F9),
    surfaceDefault: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF2EFF1),
    surfaceBrandSoft: Color(0xFFFCE8F0),
    borderDefault: Color(0xFFE4E0E3),
    borderStrong: Color(0xFFCAC4C8),
    borderBrand: Color(0xFFE74984),
    textDefault: Color(0xFF1B171A),
    textMuted: Color(0xFF7C7379),
    textInverse: Color(0xFFFFFFFF),
    textBrand: Color(0xFFA9144B),
    textOnBrand: Color(0xFFFFFFFF),
    overlayScrim: Color(0x801B171A),
    actionPrimary: Color(0xFFE6256D),
    actionPrimaryHover: Color(0xFFA9144B),
    actionPrimaryPressed: Color(0xFF64102E),
    actionDanger: Color(0xFFD92D20),
    actionDisabledBg: Color(0xFFE4E0E3),
    actionDisabledFg: Color(0xFFA39BA0),
    actionFocusRing: Color(0xFFE6256D),
    feedbackSuccess: Color(0xFF1E9E63),
    feedbackSuccessLight: Color(0xFFE4F6ED),
    feedbackSuccessDark: Color(0xFF14764A),
    feedbackWarning: Color(0xFFD98E04),
    feedbackWarningLight: Color(0xFFFDF3E0),
    feedbackWarningDark: Color(0xFFA66B00),
    feedbackError: Color(0xFFD92D20),
    feedbackErrorLight: Color(0xFFFCE9E7),
    feedbackErrorDark: Color(0xFFA81E14),
    feedbackInfo: Color(0xFF2563EB),
    feedbackInfoLight: Color(0xFFE6EDFD),
    feedbackInfoDark: Color(0xFF1D4ED8),
  );

  /// Dark theme color tokens based on Figma specs.
  static const dark = AppColorTokens(
    bgDefault: Color(0xFF16131A),
    bgSubtle: Color(0xFF1B171A),
    surfaceDefault: Color(0xFF2A2429),
    surfaceSunken: Color(0xFF1B171A),
    surfaceBrandSoft: Color(0xFF64102E),
    borderDefault: Color(0xFF413A3E),
    borderStrong: Color(0xFF5A5257),
    borderBrand: Color(0xFFE74984),
    textDefault: Color(0xFFFAF8F9),
    textMuted: Color(0xFFA39BA0),
    textInverse: Color(0xFF1B171A),
    textBrand: Color(0xFFE74984),
    textOnBrand: Color(0xFFFFFFFF),
    overlayScrim: Color(0xB316131A),
    actionPrimary: Color(0xFFE6256D),
    actionPrimaryHover: Color(0xFFE74984),
    actionPrimaryPressed: Color(0xFFA9144B),
    actionDanger: Color(0xFFD92D20),
    actionDisabledBg: Color(0xFF413A3E),
    actionDisabledFg: Color(0xFF7C7379),
    actionFocusRing: Color(0xFFE74984),
    feedbackSuccess: Color(0xFF1E9E63),
    feedbackSuccessLight: Color(0xFF14764A),
    feedbackSuccessDark: Color(0xFF14764A),
    feedbackWarning: Color(0xFFD98E04),
    feedbackWarningLight: Color(0xFFA66B00),
    feedbackWarningDark: Color(0xFFA66B00),
    feedbackError: Color(0xFFD92D20),
    feedbackErrorLight: Color(0xFFA81E14),
    feedbackErrorDark: Color(0xFFA81E14),
    feedbackInfo: Color(0xFF2563EB),
    feedbackInfoLight: Color(0xFF1D4ED8),
    feedbackInfoDark: Color(0xFF1D4ED8),
  );

  /// Helper getter to retrieve tokens directly from BuildContext.
  /// Falls back to dark or light tokens matching current Theme brightness
  /// if ThemeExtension is omitted.
  static AppColorTokens of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppColorTokens>() ??
        (theme.brightness == Brightness.dark
            ? AppColorTokens.dark
            : AppColorTokens.light);
  }

  @override
  AppColorTokens copyWith({
    Color? bgDefault,
    Color? bgSubtle,
    Color? surfaceDefault,
    Color? surfaceSunken,
    Color? surfaceBrandSoft,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderBrand,
    Color? textDefault,
    Color? textMuted,
    Color? textInverse,
    Color? textBrand,
    Color? textOnBrand,
    Color? overlayScrim,
    Color? actionPrimary,
    Color? actionPrimaryHover,
    Color? actionPrimaryPressed,
    Color? actionDanger,
    Color? actionDisabledBg,
    Color? actionDisabledFg,
    Color? actionFocusRing,
    Color? feedbackSuccess,
    Color? feedbackSuccessLight,
    Color? feedbackSuccessDark,
    Color? feedbackWarning,
    Color? feedbackWarningLight,
    Color? feedbackWarningDark,
    Color? feedbackError,
    Color? feedbackErrorLight,
    Color? feedbackErrorDark,
    Color? feedbackInfo,
    Color? feedbackInfoLight,
    Color? feedbackInfoDark,
  }) {
    return AppColorTokens(
      bgDefault: bgDefault ?? this.bgDefault,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      surfaceDefault: surfaceDefault ?? this.surfaceDefault,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceBrandSoft: surfaceBrandSoft ?? this.surfaceBrandSoft,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderBrand: borderBrand ?? this.borderBrand,
      textDefault: textDefault ?? this.textDefault,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      textBrand: textBrand ?? this.textBrand,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      overlayScrim: overlayScrim ?? this.overlayScrim,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionPrimaryHover: actionPrimaryHover ?? this.actionPrimaryHover,
      actionPrimaryPressed: actionPrimaryPressed ?? this.actionPrimaryPressed,
      actionDanger: actionDanger ?? this.actionDanger,
      actionDisabledBg: actionDisabledBg ?? this.actionDisabledBg,
      actionDisabledFg: actionDisabledFg ?? this.actionDisabledFg,
      actionFocusRing: actionFocusRing ?? this.actionFocusRing,
      feedbackSuccess: feedbackSuccess ?? this.feedbackSuccess,
      feedbackSuccessLight: feedbackSuccessLight ?? this.feedbackSuccessLight,
      feedbackSuccessDark: feedbackSuccessDark ?? this.feedbackSuccessDark,
      feedbackWarning: feedbackWarning ?? this.feedbackWarning,
      feedbackWarningLight: feedbackWarningLight ?? this.feedbackWarningLight,
      feedbackWarningDark: feedbackWarningDark ?? this.feedbackWarningDark,
      feedbackError: feedbackError ?? this.feedbackError,
      feedbackErrorLight: feedbackErrorLight ?? this.feedbackErrorLight,
      feedbackErrorDark: feedbackErrorDark ?? this.feedbackErrorDark,
      feedbackInfo: feedbackInfo ?? this.feedbackInfo,
      feedbackInfoLight: feedbackInfoLight ?? this.feedbackInfoLight,
      feedbackInfoDark: feedbackInfoDark ?? this.feedbackInfoDark,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) {
      return this;
    }
    return AppColorTokens(
      bgDefault: Color.lerp(bgDefault, other.bgDefault, t)!,
      bgSubtle: Color.lerp(bgSubtle, other.bgSubtle, t)!,
      surfaceDefault: Color.lerp(surfaceDefault, other.surfaceDefault, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      surfaceBrandSoft: Color.lerp(surfaceBrandSoft, other.surfaceBrandSoft, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderBrand: Color.lerp(borderBrand, other.borderBrand, t)!,
      textDefault: Color.lerp(textDefault, other.textDefault, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textBrand: Color.lerp(textBrand, other.textBrand, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      overlayScrim: Color.lerp(overlayScrim, other.overlayScrim, t)!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      actionPrimaryHover: Color.lerp(actionPrimaryHover, other.actionPrimaryHover, t)!,
      actionPrimaryPressed: Color.lerp(actionPrimaryPressed, other.actionPrimaryPressed, t)!,
      actionDanger: Color.lerp(actionDanger, other.actionDanger, t)!,
      actionDisabledBg: Color.lerp(actionDisabledBg, other.actionDisabledBg, t)!,
      actionDisabledFg: Color.lerp(actionDisabledFg, other.actionDisabledFg, t)!,
      actionFocusRing: Color.lerp(actionFocusRing, other.actionFocusRing, t)!,
      feedbackSuccess: Color.lerp(feedbackSuccess, other.feedbackSuccess, t)!,
      feedbackSuccessLight: Color.lerp(feedbackSuccessLight, other.feedbackSuccessLight, t)!,
      feedbackSuccessDark: Color.lerp(feedbackSuccessDark, other.feedbackSuccessDark, t)!,
      feedbackWarning: Color.lerp(feedbackWarning, other.feedbackWarning, t)!,
      feedbackWarningLight: Color.lerp(feedbackWarningLight, other.feedbackWarningLight, t)!,
      feedbackWarningDark: Color.lerp(feedbackWarningDark, other.feedbackWarningDark, t)!,
      feedbackError: Color.lerp(feedbackError, other.feedbackError, t)!,
      feedbackErrorLight: Color.lerp(feedbackErrorLight, other.feedbackErrorLight, t)!,
      feedbackErrorDark: Color.lerp(feedbackErrorDark, other.feedbackErrorDark, t)!,
      feedbackInfo: Color.lerp(feedbackInfo, other.feedbackInfo, t)!,
      feedbackInfoLight: Color.lerp(feedbackInfoLight, other.feedbackInfoLight, t)!,
      feedbackInfoDark: Color.lerp(feedbackInfoDark, other.feedbackInfoDark, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppColorTokens &&
        other.bgDefault == bgDefault &&
        other.bgSubtle == bgSubtle &&
        other.surfaceDefault == surfaceDefault &&
        other.surfaceSunken == surfaceSunken &&
        other.surfaceBrandSoft == surfaceBrandSoft &&
        other.borderDefault == borderDefault &&
        other.borderStrong == borderStrong &&
        other.borderBrand == borderBrand &&
        other.textDefault == textDefault &&
        other.textMuted == textMuted &&
        other.textInverse == textInverse &&
        other.textBrand == textBrand &&
        other.textOnBrand == textOnBrand &&
        other.overlayScrim == overlayScrim &&
        other.actionPrimary == actionPrimary &&
        other.actionPrimaryHover == actionPrimaryHover &&
        other.actionPrimaryPressed == actionPrimaryPressed &&
        other.actionDanger == actionDanger &&
        other.actionDisabledBg == actionDisabledBg &&
        other.actionDisabledFg == actionDisabledFg &&
        other.actionFocusRing == actionFocusRing &&
        other.feedbackSuccess == feedbackSuccess &&
        other.feedbackSuccessLight == feedbackSuccessLight &&
        other.feedbackSuccessDark == feedbackSuccessDark &&
        other.feedbackWarning == feedbackWarning &&
        other.feedbackWarningLight == feedbackWarningLight &&
        other.feedbackWarningDark == feedbackWarningDark &&
        other.feedbackError == feedbackError &&
        other.feedbackErrorLight == feedbackErrorLight &&
        other.feedbackErrorDark == feedbackErrorDark &&
        other.feedbackInfo == feedbackInfo &&
        other.feedbackInfoLight == feedbackInfoLight &&
        other.feedbackInfoDark == feedbackInfoDark;
  }

  @override
  int get hashCode => Object.hashAll([
        bgDefault,
        bgSubtle,
        surfaceDefault,
        surfaceSunken,
        surfaceBrandSoft,
        borderDefault,
        borderStrong,
        borderBrand,
        textDefault,
        textMuted,
        textInverse,
        textBrand,
        textOnBrand,
        overlayScrim,
        actionPrimary,
        actionPrimaryHover,
        actionPrimaryPressed,
        actionDanger,
        actionDisabledBg,
        actionDisabledFg,
        actionFocusRing,
        feedbackSuccess,
        feedbackSuccessLight,
        feedbackSuccessDark,
        feedbackWarning,
        feedbackWarningLight,
        feedbackWarningDark,
        feedbackError,
        feedbackErrorLight,
        feedbackErrorDark,
        feedbackInfo,
        feedbackInfoLight,
        feedbackInfoDark,
      ]);
}

/// Extension on BuildContext for quick access to color tokens.
extension AppColorsExtension on BuildContext {
  AppColorTokens get colors => AppColorTokens.of(this);
}

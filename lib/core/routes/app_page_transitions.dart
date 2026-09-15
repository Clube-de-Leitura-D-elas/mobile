import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App-wide helper for creating standardized page route transitions.
///
/// Features:
/// - [createPushPage]: Creates a push page transition. Uses Cupertino page transition on iOS
///   (which includes swipe back and Cupertino scaffold styling) and Material page transition on Android/other platforms.
/// - [createFadePage]: Creates a custom page transition with a smooth FadeTransition for non-push route switches.
abstract final class AppPageTransitions {
  /// Creates a page transition suitable for push navigation (allowing pops).
  /// Uses Cupertino style on iOS and standard Material style on other platforms.
  static Page<T> createPushPage<T>({
    required Widget child,
    required GoRouterState state,
    String? title,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPage<T>(
        key: state.pageKey,
        name: state.name ?? state.matchedLocation,
        title: title,
        child: child,
      );
    }
    return MaterialPage<T>(
      key: state.pageKey,
      name: state.name ?? state.matchedLocation,
      child: child,
    );
  }

  /// Creates a page transition with a smooth fade effect for general route transitions.
  static Page<T> createFadePage<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: state.name ?? state.matchedLocation,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
            reverseCurve: Curves.easeOut,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

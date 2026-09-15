import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late MockGoRouterState mockState;

  setUp(() {
    mockState = MockGoRouterState();
    when(() => mockState.pageKey).thenReturn(const ValueKey('test_key'));
    when(() => mockState.matchedLocation).thenReturn('/test');
    when(() => mockState.name).thenReturn('test_route');
  });

  group('AppPageTransitions', () {
    testWidgets('createPushPage creates CupertinoPage on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final page = AppPageTransitions.createPushPage(
        child: const SizedBox(),
        state: mockState,
        title: 'Title',
      );

      expect(page, isA<CupertinoPage>());
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('createPushPage creates MaterialPage on android/default', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final page = AppPageTransitions.createPushPage(
        child: const SizedBox(),
        state: mockState,
      );

      expect(page, isA<MaterialPage>());
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('createFadePage creates CustomTransitionPage with FadeTransition', (tester) async {
      final page = AppPageTransitions.createFadePage(
        child: const SizedBox(),
        state: mockState,
      );

      expect(page, isA<CustomTransitionPage>());
      final transitionPage = page as CustomTransitionPage;
      
      final widget = transitionPage.transitionsBuilder(
        MockBuildContext(),
        const AlwaysStoppedAnimation(1.0),
        const AlwaysStoppedAnimation(0.0),
        const SizedBox(),
      );

      expect(widget, isA<FadeTransition>());
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}

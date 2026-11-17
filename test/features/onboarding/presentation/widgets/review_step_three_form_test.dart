import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/presentation/widgets/review_step_three_form.dart';
import 'package:mobile/l10n/app_localizations.dart';

Widget _wrap(UserReviewProfile profile, ValueChanged<UserReviewProfile> onChanged) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('pt', 'BR'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: ReviewStepThreeForm(profile: profile, onChanged: onChanged),
    ),
  );
}

void main() {
  testWidgets('shows the saved answers', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(
          hasOtherReadingGroup: true,
          wantsToCoordinate: false,
          bookIndication: 'A hora da estrela',
          expectations: 'Ler mais',
        ),
        (_) {},
      ),
    );

    expect(find.text('Sim'), findsOneWidget);
    expect(find.text('Não'), findsOneWidget);
    expect(find.text('A hora da estrela'), findsOneWidget);
    expect(find.text('Ler mais'), findsOneWidget);

    final dropdowns = tester
        .widgetList<AppDropdown<bool>>(find.byType(AppDropdown<bool>))
        .toList();
    expect(dropdowns[0].itemLabelBuilder!(false), 'Não');
    expect(dropdowns[1].itemLabelBuilder!(true), 'Sim');
  });

  testWidgets('sends the two questions as booleans', (tester) async {
    UserReviewProfile? changed;
    await tester.pumpWidget(
      _wrap(const UserReviewProfile(), (profile) => changed = profile),
    );

    final dropdowns = tester
        .widgetList<AppDropdown<bool>>(find.byType(AppDropdown<bool>))
        .toList();

    dropdowns[0].onChanged(true);
    expect(changed?.hasOtherReadingGroup, isTrue);

    dropdowns[1].onChanged(false);
    expect(changed?.wantsToCoordinate, isFalse);
  });

  testWidgets('sends the book and expectations text', (tester) async {
    UserReviewProfile? changed;
    await tester.pumpWidget(
      _wrap(const UserReviewProfile(), (profile) => changed = profile),
    );

    await tester.enterText(find.byType(TextField).at(0), 'A hora da estrela');
    expect(changed?.bookIndication, 'A hora da estrela');

    await tester.enterText(find.byType(TextField).at(1), 'Ler mais');
    expect(changed?.expectations, 'Ler mais');
  });
}

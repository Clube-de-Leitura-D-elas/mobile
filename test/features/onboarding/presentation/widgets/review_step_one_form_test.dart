import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/presentation/widgets/review_step_one_form.dart';
import 'package:mobile/l10n/app_localizations.dart';

Widget _wrap(
  UserReviewProfile profile,
  ValueChanged<UserReviewProfile> onChanged,
) {
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
      body: ReviewStepOneForm(profile: profile, onChanged: onChanged),
    ),
  );
}

void main() {
  final phoneField = find.byType(TextField).at(2);
  final birthDateField = find.byType(TextField).at(3);

  testWidgets('shows prefilled phone and birth date masked', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(phone: '51999999999', birthDate: '05/03/1990'),
        (_) {},
      ),
    );

    expect(find.text('(51) 99999-9999'), findsOneWidget);
    expect(find.text('05/03/1990'), findsOneWidget);
  });

  testWidgets('shows the birth date format hint', (tester) async {
    await tester.pumpWidget(_wrap(const UserReviewProfile(), (_) {}));

    expect(find.text('DD/MM/AAAA'), findsOneWidget);
  });

  testWidgets('masks phone and birth date pasted as raw digits', (
    tester,
  ) async {
    UserReviewProfile? changed;
    await tester.pumpWidget(
      _wrap(const UserReviewProfile(), (profile) => changed = profile),
    );

    await tester.enterText(phoneField, '5133333333');
    expect(changed?.phone, '(51) 3333-3333');

    await tester.enterText(birthDateField, '05031990');
    expect(changed?.birthDate, '05/03/1990');
  });
}

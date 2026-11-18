import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/onboarding/domain/entities/city.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/domain/entities/zone.dart';
import 'package:mobile/features/onboarding/presentation/widgets/review_step_one_form.dart';
import 'package:mobile/l10n/app_localizations.dart';

Widget _wrap(
  UserReviewProfile profile,
  ValueChanged<UserReviewProfile> onChanged, {
  List<City> cities = const [],
}) {
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
      body: ReviewStepOneForm(
        profile: profile,
        cities: cities,
        onChanged: onChanged,
      ),
    ),
  );
}

void main() {
  final phoneField = find.byType(TextField).at(2);
  final birthDateField = find.byType(TextField).at(3);

  const cities = [
    City(
      id: 'poa',
      name: 'Porto Alegre',
      uf: 'RS',
      zones: [
        Zone(id: 'poa-sul', name: 'Zona Sul'),
        Zone(id: 'poa-centro', name: 'Centro Histórico'),
      ],
    ),
    City(
      id: 'recife',
      name: 'Recife',
      uf: 'PE',
    ),
    City(
      id: 'sp',
      name: 'São Paulo',
      uf: 'SP',
      zones: [
        Zone(id: 'sp-sul', name: 'Zona Sul'),
        Zone(id: 'sp-pinheiros', name: 'Pinheiros'),
      ],
    ),
  ];

  testWidgets('shows prefilled phone and birth date masked', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(
          phone: '+55 51 99999-9999',
          birthDate: '5/3/1990',
        ),
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

  testWidgets('sends the name text', (tester) async {
    UserReviewProfile? changed;
    await tester.pumpWidget(
      _wrap(const UserReviewProfile(), (profile) => changed = profile),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Maria');
    expect(changed?.name, 'Maria');
  });

  testWidgets('sends the selected zone', (tester) async {
    UserReviewProfile? changed;
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(cityId: 'poa', cityName: 'Porto Alegre'),
        (profile) => changed = profile,
        cities: cities,
      ),
    );

    await tester.tap(find.text('Selecione uma região'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zona Sul'));
    await tester.pumpAndSettle();

    expect(changed?.zoneId, 'poa-sul');
    expect(changed?.zoneName, 'Zona Sul');
  });

  testWidgets('keeps the login e-mail read-only', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(email: 'maria@example.com'),
        (_) {},
      ),
    );

    final email = tester.widget<AppTextField>(
      find.widgetWithText(AppTextField, 'E-mail'),
    );
    expect(email.enabled, isFalse);
    expect(find.text('maria@example.com'), findsOneWidget);
  });

  testWidgets('preselects city and zone by id', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(
          cityId: 'poa',
          cityName: 'Porto Alegre',
          zoneId: 'poa-sul',
          zoneName: 'Zona Sul',
        ),
        (_) {},
        cities: cities,
      ),
    );

    expect(find.text('Porto Alegre'), findsOneWidget);
    expect(find.text('Zona Sul'), findsOneWidget);
  });

  testWidgets('does not preselect when the id is not in the list', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(
          cityId: 'old-city',
          cityName: 'Cidade Antiga',
          zoneId: 'old-zone',
          zoneName: 'Zona Antiga',
        ),
        (_) {},
        cities: cities,
      ),
    );

    expect(find.text('Selecione uma cidade'), findsOneWidget);
    expect(find.text('Cidade Antiga'), findsNothing);
    expect(find.text('Zona Antiga'), findsNothing);
  });

  testWidgets('selecting a city clears the previous zone', (tester) async {
    UserReviewProfile? changed;
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(
          cityId: 'poa',
          cityName: 'Porto Alegre',
          zoneId: 'poa-sul',
          zoneName: 'Zona Sul',
        ),
        (profile) => changed = profile,
        cities: cities,
      ),
    );

    await tester.tap(find.text('Porto Alegre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('São Paulo'));
    await tester.pumpAndSettle();

    expect(changed?.cityId, 'sp');
    expect(changed?.cityName, 'São Paulo');
    expect(changed?.zoneId, isNull);
    expect(changed?.zoneName, isEmpty);
  });

  testWidgets('filters zones by the selected city', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(cityId: 'poa', cityName: 'Porto Alegre'),
        (_) {},
        cities: cities,
      ),
    );

    await tester.tap(find.text('Selecione uma região'));
    await tester.pumpAndSettle();

    expect(find.text('Centro Histórico'), findsOneWidget);
    expect(find.text('Zona Sul'), findsOneWidget);
    expect(find.text('Pinheiros'), findsNothing);
  });

  testWidgets('disables the zone and shows a hint when the city has no zones', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const UserReviewProfile(cityId: 'recife', cityName: 'Recife'),
        (_) {},
        cities: cities,
      ),
    );

    expect(
      find.text('Esta cidade ainda não tem regiões cadastradas'),
      findsOneWidget,
    );

    final region = tester.widget<AppDropdown<Zone>>(
      find.byWidgetPredicate((widget) => widget is AppDropdown<Zone>),
    );
    expect(region.enabled, isFalse);
  });

  testWidgets('disables the zone select until a city is chosen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const UserReviewProfile(), (_) {}, cities: cities),
    );

    final region = tester.widget<AppDropdown<Zone>>(
      find.byWidgetPredicate(
        (widget) => widget is AppDropdown<Zone>,
      ),
    );
    expect(region.enabled, isFalse);
  });
}

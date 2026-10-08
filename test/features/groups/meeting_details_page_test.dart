import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_state.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockMeetingDetailsCubit extends Mock implements MeetingDetailsCubit {}

class MockMeetingPhotosCubit extends Mock implements MeetingPhotosCubit {}

Widget _wrap(MeetingDetailsState state) {
  final cubit = MockMeetingDetailsCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => Stream.value(state));
  final photosCubit = MockMeetingPhotosCubit();
  const photosState = MeetingPhotosState(status: MeetingPhotosStatus.loaded);
  when(() => photosCubit.state).thenReturn(photosState);
  when(() => photosCubit.stream).thenAnswer((_) => const Stream.empty());

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
    home: MultiBlocProvider(
      providers: [
        BlocProvider<MeetingDetailsCubit>.value(value: cubit),
        BlocProvider<MeetingPhotosCubit>.value(value: photosCubit),
      ],
      child: const MeetingDetailsPage(),
    ),
  );
}

void main() {
  // Data em UTC que cai no mesmo dia em qualquer fuso do Brasil.
  final meeting = MeetingDetailsEntity(
    id: 'meeting-1',
    number: 12,
    date: DateTime.utc(2026, 8, 22, 15),
    bookTitle: 'Dom Casmurro',
    hostName: 'Beatriz Souza',
    locationName: 'Café Literário',
    locationAddress: 'Rua das Flores, 12',
    description: 'Neste encontro discutimos os principais temas do livro.',
  );

  testWidgets('shows a loading indicator with a back header', (tester) async {
    await tester.pumpWidget(_wrap(const MeetingDetailsLoading()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Detalhes do encontro'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('shows the error message with a back header', (tester) async {
    await tester.pumpWidget(
      _wrap(const MeetingDetailsError('Encontro não encontrado.')),
    );

    expect(find.text('Encontro não encontrado.'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('renders title, data rows and description', (tester) async {
    await tester.pumpWidget(_wrap(MeetingDetailsLoaded(meeting)));

    expect(find.text('Encontro 12'), findsOneWidget);
    expect(find.text('Data: 22/08/2026'), findsOneWidget);
    expect(find.text('Livro: Dom Casmurro'), findsOneWidget);
    expect(find.text('Anfitriã: Beatriz Souza'), findsOneWidget);
    expect(
      find.text('Local: Café Literário - Rua das Flores, 12'),
      findsOneWidget,
    );
    expect(find.text('Descrição'), findsOneWidget);
    expect(
      find.text('Neste encontro discutimos os principais temas do livro.'),
      findsOneWidget,
    );
    expect(
      tester.widgetList<AppIcon>(find.byType(AppIcon)).map((i) => i.icon),
      containsAllInOrder([
        AppIcons.calendar,
        AppIcons.book,
        AppIcons.user,
        AppIcons.location,
      ]),
    );
    expect(find.byTooltip('Voltar'), findsOneWidget);
    expect(find.text('Fotos do encontro'), findsOneWidget);
  });

  testWidgets('hides the description section when there is no description', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        MeetingDetailsLoaded(
          MeetingDetailsEntity(
            id: meeting.id,
            number: meeting.number,
            date: meeting.date,
            bookTitle: meeting.bookTitle,
            hostName: meeting.hostName,
            description: '   ',
          ),
        ),
      ),
    );

    expect(find.text('Descrição'), findsNothing);
    expect(find.byKey(const ValueKey('meeting-description')), findsNothing);
  });

  testWidgets('shows a placeholder when there is no cover photo', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(MeetingDetailsLoaded(meeting)));

    expect(
      find.byKey(const ValueKey('meeting-cover-placeholder')),
      findsOneWidget,
    );
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows fallbacks for meetings without number, date or place', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const MeetingDetailsLoaded(
          MeetingDetailsEntity(
            id: 'draft',
            bookTitle: 'Dom Casmurro',
            hostName: 'Beatriz Souza',
          ),
        ),
      ),
    );

    expect(find.text('Encontro'), findsOneWidget);
    expect(find.text('Data: a definir'), findsOneWidget);
    expect(find.text('Local: a definir'), findsOneWidget);
  });

  testWidgets('long description and address wrap without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const longAddress =
        'Avenida Professora Doutora Maria Aparecida de Oliveira Figueiredo, '
        '1450, bloco B, sala 302 - Cristal, Porto Alegre - RS';
    final longDescription = List.filled(40, 'Conversa muito rica.').join(' ');

    await tester.pumpWidget(
      _wrap(
        MeetingDetailsLoaded(
          MeetingDetailsEntity(
            id: 'meeting-1',
            number: 12,
            date: DateTime.utc(2026, 8, 22, 15),
            bookTitle: 'Dom Casmurro',
            hostName: 'Beatriz Souza',
            locationName: 'Café Literário',
            locationAddress: longAddress,
            description: longDescription,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final address = find.text('Local: Café Literário - $longAddress');
    expect(address, findsOneWidget);
    expect(tester.getSize(address).height, greaterThan(24));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -2000),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('meeting-description')), findsOneWidget);
  });
}

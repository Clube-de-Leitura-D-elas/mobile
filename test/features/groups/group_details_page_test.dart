import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository mockRepository;

  const group = GroupDetailsEntity(
    name: '45',
    genres: ['Ficção', 'Aventura'],
    participantCount: 34,
    city: 'Porto Alegre',
    stateCode: 'RS',
  );

  setUp(() {
    mockRepository = MockGroupRepository();
    serviceLocator.allowReassignment = true;
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
    serviceLocator.registerFactory<GroupRepository>(() => mockRepository);
  });

  tearDown(() {
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
  });

  Widget buildSubject() => MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt', 'BR'),
    home: BlocProvider(
      create: (_) =>
          GroupDetailsCubit(groupRepository: serviceLocator<GroupRepository>())
            ..load('group-1'),
      child: const GroupDetailsPage(),
    ),
  );

  testWidgets('renders loading state while the group request is pending', (
    tester,
  ) async {
    final response = Completer<Result<GroupDetailsEntity, SupabaseFailure>>();
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) => response.future);

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(GroupDetailsScreen), findsNothing);

    response.complete(
      const Failure(
        FunctionSupabaseFailure(message: 'Falha ao carregar grupo'),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('renders the error state message', (tester) async {
    when(() => mockRepository.getGroupDetails('group-1')).thenAnswer(
      (_) async => const Failure(
        FunctionSupabaseFailure(message: 'Falha ao carregar grupo'),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Falha ao carregar grupo'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(GroupDetailsScreen), findsNothing);
  });

  testWidgets('renders group details in the loaded state', (tester) async {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(group));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(GroupDetailsScreen), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.text('Ficção'), findsOneWidget);
    expect(find.text('Aventura'), findsOneWidget);
    expect(find.text('34 participantes'), findsOneWidget);
    expect(find.text('Porto Alegre, RS'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('uses the network cover image when the group has a URL', (
    tester,
  ) async {
    const groupWithCover = GroupDetailsEntity(
      name: '45',
      genres: ['Ficção'],
      participantCount: 34,
      city: 'Porto Alegre',
      stateCode: 'RS',
      coverImageUrl: 'https://example.com/group-cover.jpg',
    );
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(groupWithCover));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final screen = tester.widget<GroupDetailsScreen>(
      find.byType(GroupDetailsScreen),
    );
    expect(screen.coverImage, isA<NetworkImage>());
    expect(
      (screen.coverImage! as NetworkImage).url,
      'https://example.com/group-cover.jpg',
    );
  });
}

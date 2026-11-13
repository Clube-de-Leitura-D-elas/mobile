import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_failure.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_state.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  const summary = ProfileSummaryEntity(
    booksReadCount: 5,
    groups: [ProfileGroupEntity(id: 'g-1', number: 1)],
  );

  setUp(() => repository = MockProfileRepository());

  ProfileSummaryCubit build() => ProfileSummaryCubit(repository: repository);

  test('começa carregando', () {
    expect(build().state, const ProfileSummaryLoading());
  });

  blocTest<ProfileSummaryCubit, ProfileSummaryState>(
    'carrega o resumo do perfil',
    setUp: () => when(
      () => repository.getProfileSummary(),
    ).thenAnswer((_) async => const Success(summary)),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProfileSummaryLoading(),
      const ProfileSummaryLoaded(summary),
    ],
  );

  blocTest<ProfileSummaryCubit, ProfileSummaryState>(
    'mostra o erro e carrega de novo na nova tentativa',
    setUp: () {
      final answers = <Result<ProfileSummaryEntity, ProfileSummaryFailure>>[
        const Failure(ProfileSummaryNetworkFailure()),
        const Success(summary),
      ];
      when(
        () => repository.getProfileSummary(),
      ).thenAnswer((_) async => answers.removeAt(0));
    },
    build: build,
    act: (cubit) async {
      await cubit.load();
      await cubit.load();
    },
    expect: () => [
      const ProfileSummaryLoading(),
      const ProfileSummaryError(ProfileSummaryNetworkFailure()),
      const ProfileSummaryLoading(),
      const ProfileSummaryLoaded(summary),
    ],
  );

  group('refresh', () {
    const updated = ProfileSummaryEntity(booksReadCount: 6);

    blocTest<ProfileSummaryCubit, ProfileSummaryState>(
      'com o resumo na tela, troca os dados sem voltar ao carregamento',
      setUp: () => when(
        () => repository.getProfileSummary(),
      ).thenAnswer((_) async => const Success(updated)),
      build: build,
      seed: () => const ProfileSummaryLoaded(summary),
      act: (cubit) => cubit.refresh(),
      expect: () => [const ProfileSummaryLoaded(updated)],
    );

    blocTest<ProfileSummaryCubit, ProfileSummaryState>(
      'se falhar, mantém o resumo que já estava na tela',
      setUp: () => when(
        () => repository.getProfileSummary(),
      ).thenAnswer((_) async => const Failure(ProfileSummaryNetworkFailure())),
      build: build,
      seed: () => const ProfileSummaryLoaded(summary),
      act: (cubit) => cubit.refresh(),
      expect: () => <ProfileSummaryState>[],
    );

    blocTest<ProfileSummaryCubit, ProfileSummaryState>(
      'depois de um erro, carrega de novo mostrando o carregamento',
      setUp: () => when(
        () => repository.getProfileSummary(),
      ).thenAnswer((_) async => const Success(summary)),
      build: build,
      seed: () => const ProfileSummaryError(ProfileSummaryNetworkFailure()),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const ProfileSummaryLoading(),
        const ProfileSummaryLoaded(summary),
      ],
    );

    blocTest<ProfileSummaryCubit, ProfileSummaryState>(
      'descarta a resposta de uma atualização ultrapassada por uma carga',
      setUp: () {
        final slow =
            Completer<Result<ProfileSummaryEntity, ProfileSummaryFailure>>();
        final answers = [
          slow.future,
          Future.value(
            const Success<ProfileSummaryEntity, ProfileSummaryFailure>(updated),
          ),
        ];
        when(
          () => repository.getProfileSummary(),
        ).thenAnswer((_) => answers.removeAt(0));
        addTearDown(() {
          if (!slow.isCompleted) slow.complete(const Success(summary));
        });
        // A atualização lenta responde por último, com dados velhos.
        Future<void>.delayed(
          const Duration(milliseconds: 10),
          () => slow.complete(const Success(summary)),
        );
      },
      build: build,
      seed: () => const ProfileSummaryLoaded(summary),
      act: (cubit) async {
        final refresh = cubit.refresh();
        await cubit.load();
        await refresh;
      },
      wait: const Duration(milliseconds: 20),
      expect: () => [
        const ProfileSummaryLoading(),
        const ProfileSummaryLoaded(updated),
      ],
    );

    test('não emite depois de fechado', () async {
      final pending =
          Completer<Result<ProfileSummaryEntity, ProfileSummaryFailure>>();
      when(
        () => repository.getProfileSummary(),
      ).thenAnswer((_) => pending.future);
      final cubit = build();
      final states = <ProfileSummaryState>[];
      final sub = cubit.stream.listen(states.add);

      final loading = cubit.load();
      await cubit.close();
      pending.complete(const Success(summary));
      await loading;
      await sub.cancel();

      expect(states, [const ProfileSummaryLoading()]);
    });
  });
}

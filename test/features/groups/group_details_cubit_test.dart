import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository mockRepository;

  const testGroup = GroupDetailsEntity(
    name: '45',
    genres: ['Ficção', 'Aventura'],
    participantCount: 34,
    city: 'Porto Alegre',
    stateCode: 'RS',
  );

  setUp(() {
    mockRepository = MockGroupRepository();
  });

  test('starts in loading state', () async {
    final cubit = GroupDetailsCubit(groupRepository: mockRepository);
    addTearDown(cubit.close);

    expect(cubit.state, const GroupDetailsLoading());
  });

  group('GroupDetailsCubit', () {
    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'emits loading and loaded when group details load successfully',
      build: () {
        when(
          () => mockRepository.getGroupDetails('group-1'),
        ).thenAnswer((_) async => const Success(testGroup));
        return GroupDetailsCubit(groupRepository: mockRepository);
      },
      act: (cubit) => cubit.load('group-1'),
      expect: () => [
        const GroupDetailsLoading(),
        const GroupDetailsLoaded(testGroup),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'emits loading and error when group details fail to load',
      build: () {
        when(() => mockRepository.getGroupDetails('group-1')).thenAnswer(
          (_) async => const Failure(
            FunctionSupabaseFailure(message: 'Falha ao carregar grupo'),
          ),
        );
        return GroupDetailsCubit(groupRepository: mockRepository);
      },
      act: (cubit) => cubit.load('group-1'),
      expect: () => [
        const GroupDetailsLoading(),
        const GroupDetailsError('Falha ao carregar grupo'),
      ],
    );
  });
}

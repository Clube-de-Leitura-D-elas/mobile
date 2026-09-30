/*import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_state.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';

abstract class GroupRoutes {
  static const String groupDetails = '/group-details';

  static List<RouteBase> get routes => [
    GoRoute(
      path: groupDetails,
      pageBuilder: (context, state) {
        final groupId = state.uri.queryParameters['group_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider<GroupDetailsCubit>(
            create: (_) {
              // MOCK TEMPORÁRIO LOCAL
              final mockCubit = MockGroupDetailsCubit();
              mockCubit.load(groupId);
              return mockCubit;
            },
            child: const GroupDetailsPage(),
          ),
        );
      },
    ),
  ];
}

class MockGroupDetailsCubit extends GroupDetailsCubit {
  MockGroupDetailsCubit()
    : super(groupRepository: serviceLocator<GroupRepository>());

  @override
  Future<void> load(String groupId) async {
    emit(const GroupDetailsLoading());

    await Future.delayed(const Duration(milliseconds: 300));

    if (isClosed) return;

    const mockGroup = GroupDetailsEntity(
      name: 'Grupo de Leitura POA',
      genres: ['Ficção', 'Romance'],
      participantCount: 12,
      city: 'Porto Alegre',
      stateCode: 'RS',
      whatsappUrl: 'https://chat.whatsapp.com/GY5v7D5dcL88PByNgp3ijb',
    );

    emit(const GroupDetailsLoaded(mockGroup));
  }
}*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_state.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';

abstract class GroupRoutes {
  static const String groupDetails = '/group-details';

  static List<RouteBase> get routes => [
    GoRoute(
      path: groupDetails,
      pageBuilder: (context, state) {
        final groupId = state.uri.queryParameters['group_id'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider<GroupDetailsCubit>(
            create: (_) {
              final mockCubit = MockGroupDetailsCubit();
              mockCubit.load(groupId);
              return mockCubit;
            },
            child: const GroupDetailsPage(),
          ),
        );
      },
    ),
  ];
}

class _FakeGroupRepository implements GroupRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockGroupDetailsCubit extends GroupDetailsCubit {
  MockGroupDetailsCubit() : super(groupRepository: _FakeGroupRepository());

  @override
  Future<void> load(String groupId) async {
    emit(const GroupDetailsLoading());

    await Future.delayed(const Duration(milliseconds: 300));

    if (isClosed) return;

    const mockGroup = GroupDetailsEntity(
      name: 'Grupo de Leitura POA',
      genres: ['Ficção', 'Romance'],
      participantCount: 12,
      city: 'Porto Alegre',
      stateCode: 'RS',
      whatsappUrl: 'https://chat.whatsapp.com/GY5v7D5dcL88PByNgp3ijb',
    );

    emit(const GroupDetailsLoaded(mockGroup));
  }
}

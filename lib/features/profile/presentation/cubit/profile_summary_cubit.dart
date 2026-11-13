import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_state.dart';

class ProfileSummaryCubit extends Cubit<ProfileSummaryState> {
  ProfileSummaryCubit({required this.repository})
    : super(const ProfileSummaryLoading());

  final ProfileRepository repository;

  int _nextRequestId = 0;

  Future<void> load() async {
    final requestId = ++_nextRequestId;
    emit(const ProfileSummaryLoading());

    final result = await repository.getProfileSummary();
    if (isClosed || requestId != _nextRequestId) return;

    emit(switch (result) {
      Success(:final data) => ProfileSummaryLoaded(data),
      Failure(:final failure) => ProfileSummaryError(failure),
    });
  }

  /// Atualiza ao voltar de outra tela (um livro marcado como lido, um grupo).
  /// Com o resumo já na tela, não volta ao carregamento nem troca os dados
  /// por um erro: só aplica a resposta se ela vier.
  Future<void> refresh() async {
    if (state is! ProfileSummaryLoaded) return load();

    final requestId = ++_nextRequestId;
    final result = await repository.getProfileSummary();
    // Uma carga mais nova, que começou depois desta, vale mais.
    if (isClosed || requestId != _nextRequestId) return;

    if (result case Success(:final data)) {
      emit(ProfileSummaryLoaded(data));
    }
  }
}

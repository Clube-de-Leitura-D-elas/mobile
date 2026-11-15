import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/meeting_guest_requests/data/models/meeting_guest_request_model.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_requests_failure.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/guest_request_decision.dart';
import 'package:mobile/features/meeting_guest_requests/domain/repository/meeting_guest_requests_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeetingGuestRequestsRepositoryImpl
    implements MeetingGuestRequestsRepository {
  MeetingGuestRequestsRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  @override
  Future<Result<List<MeetingGuestRequestEntity>, MeetingGuestRequestsFailure>>
  getRequests(String meetingId) async {
    final result = await supabaseService
        .invokeFunction<List<MeetingGuestRequestModel>>(
          functionName: 'get-meeting-guest-requests',
          method: HttpMethod.get,
          queryParameters: {'meeting_id': meetingId},
          decoder: (data) => MeetingGuestRequestModel.listFromJson(
            data as Map<String, dynamic>,
          ),
        );

    switch (result) {
      case Failure(:final failure):
        return Failure(_failureFrom(failure));
      case Success(:final data):
        final models = data.data;
        if (models == null) {
          return const Failure(MeetingGuestRequestsServerFailure());
        }
        return Success([for (final model in models) model.toDomain()]);
    }
  }

  @override
  Future<Result<void, MeetingGuestRequestsFailure>> review({
    required String requestId,
    required GuestRequestDecision decision,
  }) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'review-meeting-guest-request',
      body: {'request_id': requestId, 'action': decision.name},
    );

    return switch (result) {
      Failure(:final failure) => Failure(_failureFrom(failure)),
      Success() => const Success(null),
    };
  }

  /// O backend usa o mesmo status para casos diferentes; o texto em `error`
  /// (que chega no `message`) diz qual.
  MeetingGuestRequestsFailure _failureFrom(SupabaseFailure failure) {
    final message = failure.message;
    // 403 é a resposta esperada para quem não decide: o detalhe do encontro
    // pergunta a toda leitora que abre a tela.
    if (failure.kind != SupabaseFailureKind.forbidden) {
      debugPrint(
        '[MeetingGuestRequestsFailure] ${failure.message} (${failure.code})',
      );
    }
    return switch (failure.kind) {
      SupabaseFailureKind.network => const MeetingGuestRequestsNetworkFailure(),
      SupabaseFailureKind.unauthorized =>
        const MeetingGuestRequestsSessionExpiredFailure(),
      SupabaseFailureKind.forbidden =>
        const MeetingGuestRequestsNotReviewerFailure(),
      SupabaseFailureKind.validation =>
        const MeetingGuestRequestsInvalidFailure(),
      SupabaseFailureKind.notFound when message.contains('request not found') =>
        const GuestRequestNotFoundFailure(),
      SupabaseFailureKind.conflict when message.contains('already reviewed') =>
        const GuestRequestAlreadyReviewedFailure(),
      SupabaseFailureKind.conflict when message.contains('no longer valid') =>
        const GuestRequestNoLongerValidFailure(),
      _ => const MeetingGuestRequestsServerFailure(),
    };
  }
}

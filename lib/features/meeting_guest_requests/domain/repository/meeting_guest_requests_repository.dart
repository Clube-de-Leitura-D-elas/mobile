import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/guest_request_decision.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_requests_failure.dart';

abstract class MeetingGuestRequestsRepository {
  /// Pedidos pendentes do encontro, do mais antigo para o mais novo;
  /// [MeetingGuestRequestsNotReviewerFailure] para quem não decide o encontro.
  Future<Result<List<MeetingGuestRequestEntity>, MeetingGuestRequestsFailure>>
  getRequests(String meetingId);

  Future<Result<void, MeetingGuestRequestsFailure>> review({
    required String requestId,
    required GuestRequestDecision decision,
  });
}

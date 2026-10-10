import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';

abstract class RaffleRepository {
  Future<Result<List<RaffleParticipant>, RaffleFailure>>
  getEligibleParticipants(String meetingId);

  Future<Result<void, RaffleFailure>> confirmRaffle({
    required String meetingId,
    required List<String> selectedParticipantIds,
  });
}

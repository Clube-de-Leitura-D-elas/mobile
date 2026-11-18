import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';

abstract class RaffleRepository {
  Future<Result<List<RaffleParticipant>, RaffleFailure>>
  getEligibleParticipants([String? meetingId, String? groupId]);

  Future<Result<void, RaffleFailure>> confirmRaffle({
    String? meetingId,
    String? groupId,
    required List<String> selectedParticipantIds,
  });

  Future<Result<RaffleResult?, RaffleFailure>> getRaffleResult(
    String? meetingId, [
    String? groupId,
  ]);

  Future<Result<RaffleResult, RaffleFailure>> drawRaffle({
    String? meetingId,
    String? groupId,
    required List<String> eligibleParticipantIds,
  });

  Future<Result<void, RaffleFailure>> saveRaffleResult(
    RaffleResult result, {
    String? meetingId,
    String? groupId,
  });
}

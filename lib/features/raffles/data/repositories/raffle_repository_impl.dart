import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/datasources/raffle_remote_data_source.dart';
import 'package:mobile/features/raffles/data/models/raffle_result_model.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';

class RaffleRepositoryImpl implements RaffleRepository {
  final RaffleRemoteDataSource remoteDataSource;

  RaffleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<RaffleParticipant>, RaffleFailure>>
  getEligibleParticipants(String meetingId) async {
    try {
      final models = await remoteDataSource.getEligibleParticipants(meetingId);
      final entities = models.map((model) => model.toDomain()).toList();
      return Success(entities);
    } catch (e) {
      return Failure(
        RaffleServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Result<void, RaffleFailure>> confirmRaffle({
    required String meetingId,
    required List<String> selectedParticipantIds,
  }) async {
    try {
      await remoteDataSource.confirmRaffle(meetingId, selectedParticipantIds);
      return const Success(null);
    } catch (e) {
      return Failure(
        RaffleServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Result<RaffleResult?, RaffleFailure>> getRaffleResult(
    String meetingId,
  ) async {
    try {
      final model = await remoteDataSource.getRaffleResult(meetingId);
      return Success(model?.toDomain());
    } catch (e) {
      return Failure(
        RaffleServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Result<RaffleResult, RaffleFailure>> drawRaffle({
    required String meetingId,
    required List<String> eligibleParticipantIds,
  }) async {
    try {
      final model = await remoteDataSource.drawRaffle(
        meetingId: meetingId,
        eligibleParticipantIds: eligibleParticipantIds,
      );
      return Success(model.toDomain());
    } catch (e) {
      return Failure(
        RaffleServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Result<void, RaffleFailure>> saveRaffleResult(
    RaffleResult result,
  ) async {
    try {
      final model = RaffleResultModel(
        meetingId: result.meetingId,
        winnerId: result.winnerId,
        winnerName: result.winnerName,
        winnerAvatarUrl: result.winnerAvatarUrl,
        bookTitle: result.bookTitle,
        bookAuthor: result.bookAuthor,
        bookCoverUrl: result.bookCoverUrl,
        drawnAt: result.drawnAt ?? DateTime.now(),
      );
      await remoteDataSource.saveRaffleResult(model);
      return const Success(null);
    } catch (e) {
      return Failure(
        RaffleServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}

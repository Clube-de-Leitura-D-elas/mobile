import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/datasources/raffle_remote_data_source.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
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
}

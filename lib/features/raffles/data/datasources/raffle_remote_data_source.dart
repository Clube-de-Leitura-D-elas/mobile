import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';
import 'package:mobile/features/raffles/data/models/raffle_result_model.dart';

abstract class RaffleRemoteDataSource {
  Future<List<RaffleParticipantModel>> getEligibleParticipants(
    String meetingId,
  );
  Future<void> confirmRaffle(
    String meetingId,
    List<String> selectedParticipantIds,
  );
  Future<RaffleResultModel?> getRaffleResult(String meetingId);
  Future<RaffleResultModel> drawRaffle({
    required String meetingId,
    required List<String> eligibleParticipantIds,
  });
  Future<void> saveRaffleResult(RaffleResultModel result);
}

class RaffleRemoteDataSourceImpl implements RaffleRemoteDataSource {
  final SupabaseService supabaseService;

  RaffleRemoteDataSourceImpl({required this.supabaseService});

  @override
  Future<List<RaffleParticipantModel>> getEligibleParticipants(
    String meetingId,
  ) async {
    final result = await supabaseService
        .invokeFunction<List<RaffleParticipantModel>>(
          functionName: 'get-eligible-raffle-participants',
          body: {'meeting_id': meetingId},
          decoder: (data) {
            final list = data as List<dynamic>;
            return list
                .map(
                  (json) => RaffleParticipantModel.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();
          },
        );

    return result.match(
      (response) => response.data!,
      (failure) => throw Exception(failure.message),
    );
  }

  @override
  Future<void> confirmRaffle(
    String meetingId,
    List<String> selectedParticipantIds,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'confirm-meeting-raffle',
      body: {
        'meeting_id': meetingId,
        'eligible_participant_ids': selectedParticipantIds,
      },
    );

    result.match((_) => null, (failure) => throw Exception(failure.message));
  }

  @override
  Future<RaffleResultModel?> getRaffleResult(String meetingId) async {
    final result = await supabaseService.invokeFunction<Map<String, dynamic>?>(
      functionName: 'get-meeting-raffle-result',
      body: {'meeting_id': meetingId},
      decoder: (data) {
        if (data == null) return null;
        if (data is Map<String, dynamic>) {
          if (data.isEmpty) return null;
          return data;
        }
        return null;
      },
    );

    return result.match(
      (response) {
        final data = response.data;
        if (data == null) return null;
        return RaffleResultModel.fromJson(data);
      },
      (failure) => null,
    );
  }

  @override
  Future<RaffleResultModel> drawRaffle({
    required String meetingId,
    required List<String> eligibleParticipantIds,
  }) async {
    final result = await supabaseService.invokeFunction<RaffleResultModel>(
      functionName: 'draw-meeting-raffle',
      body: {
        'meeting_id': meetingId,
        'eligible_participant_ids': eligibleParticipantIds,
      },
      decoder: (data) =>
          RaffleResultModel.fromJson(data as Map<String, dynamic>),
    );

    return result.match(
      (response) => response.data!,
      (failure) => throw Exception(failure.message),
    );
  }

  @override
  Future<void> saveRaffleResult(RaffleResultModel result) async {
    final res = await supabaseService.invokeFunction<void>(
      functionName: 'confirm-meeting-raffle-winner',
      body: result.toJson(),
    );

    res.match((_) => null, (failure) => throw Exception(failure.message));
  }
}

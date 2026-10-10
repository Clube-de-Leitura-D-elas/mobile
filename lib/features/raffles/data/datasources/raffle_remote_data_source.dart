import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';

abstract class RaffleRemoteDataSource {
  Future<List<RaffleParticipantModel>> getEligibleParticipants(
    String meetingId,
  );
  Future<void> confirmRaffle(
    String meetingId,
    List<String> selectedParticipantIds,
  );
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
}

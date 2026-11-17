import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/raffles/data/models/raffle_participant_model.dart';
import 'package:mobile/features/raffles/data/models/raffle_result_model.dart';

abstract class RaffleRemoteDataSource {
  Future<List<RaffleParticipantModel>> getEligibleParticipants(
    String? meetingId, [
    String? groupId,
  ]);
  Future<void> confirmRaffle(
    String? meetingId,
    List<String> selectedParticipantIds, [
    String? groupId,
  ]);
  Future<RaffleResultModel?> getRaffleResult(
    String? meetingId, [
    String? groupId,
  ]);
  Future<RaffleResultModel> drawRaffle({
    String? meetingId,
    String? groupId,
    required List<String> eligibleParticipantIds,
  });
  Future<void> saveRaffleResult(
    RaffleResultModel result, {
    String? meetingId,
    String? groupId,
  });
}

/// Falha de uma Edge Function do sorteio, com o tipo e o status preservados
/// para o repository escolher o texto.
class RaffleRemoteException implements Exception {
  final SupabaseFailure failure;

  const RaffleRemoteException(this.failure);

  @override
  String toString() => 'RaffleRemoteException: ${failure.message}';
}

class RaffleRemoteDataSourceImpl implements RaffleRemoteDataSource {
  final SupabaseService supabaseService;

  RaffleRemoteDataSourceImpl({required this.supabaseService});

  Map<String, dynamic> _targetBody({String? meetingId, String? groupId}) {
    return {
      if (meetingId != null && meetingId.isNotEmpty) 'meeting_id': meetingId,
      if (groupId != null && groupId.isNotEmpty) 'group_id': groupId,
    };
  }

  @override
  Future<List<RaffleParticipantModel>> getEligibleParticipants(
    String? meetingId, [
    String? groupId,
  ]) async {
    final result = await supabaseService
        .invokeFunction<List<RaffleParticipantModel>>(
          functionName: 'get-eligible-raffle-participants',
          body: _targetBody(meetingId: meetingId, groupId: groupId),
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
      (failure) => throw RaffleRemoteException(failure),
    );
  }

  @override
  Future<void> confirmRaffle(
    String? meetingId,
    List<String> selectedParticipantIds, [
    String? groupId,
  ]) async {
    final body = _targetBody(meetingId: meetingId, groupId: groupId);
    body['eligible_participant_ids'] = selectedParticipantIds;

    final result = await supabaseService.invokeFunction<void>(
      functionName: 'confirm-meeting-raffle',
      body: body,
    );

    result.match(
      (_) => null,
      (failure) => throw RaffleRemoteException(failure),
    );
  }

  @override
  Future<RaffleResultModel?> getRaffleResult(
    String? meetingId, [
    String? groupId,
  ]) async {
    final result = await supabaseService.invokeFunction<Map<String, dynamic>?>(
      functionName: 'get-meeting-raffle-result',
      body: _targetBody(meetingId: meetingId, groupId: groupId),
      decoder: (data) {
        if (data == null) return null;
        if (data is Map<String, dynamic>) {
          if (data.isEmpty) return null;
          return data;
        }
        return null;
      },
    );

    return result.match((response) {
      final data = response.data;
      if (data == null) return null;
      return RaffleResultModel.fromJson(data);
    }, (failure) => throw RaffleRemoteException(failure));
  }

  @override
  Future<RaffleResultModel> drawRaffle({
    String? meetingId,
    String? groupId,
    required List<String> eligibleParticipantIds,
  }) async {
    final body = _targetBody(meetingId: meetingId, groupId: groupId);
    body['eligible_participant_ids'] = eligibleParticipantIds;

    final result = await supabaseService.invokeFunction<RaffleResultModel>(
      functionName: 'draw-meeting-raffle',
      body: body,
      decoder: (data) =>
          RaffleResultModel.fromJson(data as Map<String, dynamic>),
    );

    return result.match(
      (response) => response.data!,
      (failure) => throw RaffleRemoteException(failure),
    );
  }

  @override
  Future<void> saveRaffleResult(
    RaffleResultModel result, {
    String? meetingId,
    String? groupId,
  }) async {
    final body = result.toJson();
    if (meetingId != null && meetingId.isNotEmpty) {
      body['meeting_id'] = meetingId;
    }
    if (groupId != null && groupId.isNotEmpty) {
      body['group_id'] = groupId;
    }

    final res = await supabaseService.invokeFunction<void>(
      functionName: 'confirm-meeting-raffle-winner',
      body: body,
    );

    res.match((_) => null, (failure) => throw RaffleRemoteException(failure));
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';

void main() {
  test('failures of the same type are equal', () {
    expect(const RaffleServerFailure(), const RaffleServerFailure());
    expect(
      const RaffleServerFailure(),
      isNot(equals(const RaffleNetworkFailure())),
    );
  });

  test('list failures ask for a refetch', () {
    expect(
      const RaffleParticipantsChangedFailure(),
      isA<RaffleStaleListFailure>(),
    );
    expect(
      const RaffleBookAlreadyDrawnFailure(),
      isA<RaffleStaleListFailure>(),
    );
    expect(
      const RaffleBookSuggestionUnavailableFailure(),
      isA<RaffleStaleListFailure>(),
    );
    expect(
      const RaffleAlreadyRecordedFailure(),
      isNot(isA<RaffleStaleListFailure>()),
    );
  });
}

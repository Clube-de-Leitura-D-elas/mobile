import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';

void main() {
  group('RaffleFailure', () {
    const tCustomMessage = 'Mensagem de erro customizada';

    group('RaffleServerFailure', () {
      test(
        'deve usar a mensagem padrão quando nenhum argumento for fornecido',
        () {
          // Arrange & Act
          const failure = RaffleServerFailure();

          // Assert
          expect(
            failure.message,
            equals('Erro ao processar sorteio no servidor.'),
          );
        },
      );

      test('deve usar a mensagem customizada quando informada', () {
        // Arrange & Act
        const failure = RaffleServerFailure(tCustomMessage);

        // Assert
        expect(failure.message, equals(tCustomMessage));
      });

      test('deve suportar comparação por valor via Equatable', () {
        // Arrange & Act
        const failure1 = RaffleServerFailure(tCustomMessage);
        const failure2 = RaffleServerFailure(tCustomMessage);
        const failureDifferent = RaffleServerFailure('Outra mensagem');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failureDifferent)));
        expect(failure1.props, equals([tCustomMessage]));
      });
    });

    group('RaffleNetworkFailure', () {
      test(
        'deve usar a mensagem padrão quando nenhum argumento for fornecido',
        () {
          // Arrange & Act
          const failure = RaffleNetworkFailure();

          // Assert
          expect(failure.message, equals('Sem conexão com a internet.'));
        },
      );

      test('deve usar a mensagem customizada quando informada', () {
        // Arrange & Act
        const failure = RaffleNetworkFailure(tCustomMessage);

        // Assert
        expect(failure.message, equals(tCustomMessage));
      });

      test('deve suportar comparação por valor via Equatable', () {
        // Arrange & Act
        const failure1 = RaffleNetworkFailure(tCustomMessage);
        const failure2 = RaffleNetworkFailure(tCustomMessage);
        const failureDifferent = RaffleNetworkFailure('Outra mensagem');

        // Assert
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failureDifferent)));
        expect(failure1.props, equals([tCustomMessage]));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/meeting_attendance_model.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';

void main() {
  group('MeetingAttendanceModel.fromJson', () {
    test('converte os campos principais do JSON', () {
      final model = MeetingAttendanceModel.fromJson({
        'id': 'user-1',
        'name': 'Ana Souza',
        'photo_url': 'https://example.com/ana.jpg',
        'invitation_status': 'CONFIRMED',
        'presence_status': 'PRESENT',
      });

      expect(model.id, 'user-1');
      expect(model.name, 'Ana Souza');
      expect(model.photoUrl, 'https://example.com/ana.jpg');
      expect(model.invitationStatus, 'CONFIRMED');
      expect(model.presenceStatus, 'PRESENT');

      final entity = model.toDomain();

      expect(entity.invitationStatus, MeetingInvitationStatus.confirmed);
      expect(entity.presenceStatus, MeetingPresenceStatus.present);
    });

    test('aceita os campos alternativos do JSON', () {
      final model = MeetingAttendanceModel.fromJson({
        'user_id': 'user-2',
        'nome': 'Maria Silva',
        'foto': 'https://example.com/maria.jpg',
        'invitation_status': 'DECLINED',
        'presence_status': 'ABSENT',
      });

      expect(model.id, 'user-2');
      expect(model.name, 'Maria Silva');
      expect(model.photoUrl, 'https://example.com/maria.jpg');

      final entity = model.toDomain();

      expect(entity.invitationStatus, MeetingInvitationStatus.declined);
      expect(entity.presenceStatus, MeetingPresenceStatus.absent);
    });

    test('usa valores padrão quando os campos principais estão ausentes', () {
      final model = MeetingAttendanceModel.fromJson({});

      expect(model.id, '');
      expect(model.name, '');
      expect(model.photoUrl, isNull);
      expect(model.invitationStatus, 'PENDING');
      expect(model.presenceStatus, isNull);

      final entity = model.toDomain();

      expect(entity.invitationStatus, MeetingInvitationStatus.pending);
      expect(entity.presenceStatus, isNull);
    });

    test('prioriza os campos principais sobre os alternativos', () {
      final model = MeetingAttendanceModel.fromJson({
        'id': 'primary-id',
        'user_id': 'alternative-id',
        'name': 'Nome principal',
        'nome': 'Nome alternativo',
        'photo_url': 'https://example.com/principal.jpg',
        'foto': 'https://example.com/alternativa.jpg',
      });

      expect(model.id, 'primary-id');
      expect(model.name, 'Nome principal');
      expect(model.photoUrl, 'https://example.com/principal.jpg');
    });

    test('mantém a presença nula como não registrada', () {
      final model = MeetingAttendanceModel.fromJson({
        'id': 'user-1',
        'name': 'Ana Souza',
        'invitation_status': 'CONFIRMED',
        'presence_status': null,
      });

      expect(model.toDomain().presenceStatus, isNull);
    });

    test('converte status sem diferenciar maiúsculas de minúsculas', () {
      final model = MeetingAttendanceModel.fromJson({
        'id': 'user-1',
        'name': 'Ana Souza',
        'invitation_status': 'confirmed',
        'presence_status': 'present',
      });

      final entity = model.toDomain();

      expect(entity.invitationStatus, MeetingInvitationStatus.confirmed);
      expect(entity.presenceStatus, MeetingPresenceStatus.present);
    });

    test('usa pending para status de convite desconhecido', () {
      final model = MeetingAttendanceModel.fromJson({
        'id': 'user-1',
        'name': 'Ana Souza',
        'invitation_status': 'UNKNOWN',
      });

      expect(
        model.toDomain().invitationStatus,
        MeetingInvitationStatus.pending,
      );
    });

    test('converte status de presença desconhecido para null', () {
      final model = MeetingAttendanceModel.fromJson({
        'id': 'user-1',
        'name': 'Ana Souza',
        'invitation_status': 'PENDING',
        'presence_status': 'UNKNOWN',
      });

      expect(model.toDomain().presenceStatus, isNull);
    });
  });

  group('MeetingAttendanceModel.listFromJson', () {
    test('converte uma lista de participantes', () {
      final models = MeetingAttendanceModel.listFromJson([
        {'id': 'user-1', 'name': 'Ana Souza', 'invitation_status': 'CONFIRMED'},
        {'id': 'user-2', 'name': 'Maria Silva', 'invitation_status': 'PENDING'},
      ]);

      expect(models, hasLength(2));
      expect(models[0].id, 'user-1');
      expect(models[1].id, 'user-2');
    });

    test('aceita uma resposta envelopada no campo data', () {
      final models = MeetingAttendanceModel.listFromJson({
        'data': [
          {
            'id': 'user-1',
            'name': 'Ana Souza',
            'invitation_status': 'CONFIRMED',
          },
        ],
      });

      expect(models, hasLength(1));
      expect(models.single.name, 'Ana Souza');
    });

    test('retorna lista vazia quando data não existe', () {
      expect(MeetingAttendanceModel.listFromJson({}), isEmpty);
    });

    test('retorna lista vazia quando recebe null', () {
      expect(MeetingAttendanceModel.listFromJson(null), isEmpty);
    });
  });
}

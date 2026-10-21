import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/follow/domain/models/follow.dart';

void main() {
  group('Follow', () {
    group('fromJson y toJson', () {
      test('fromJson con datos completos mapea cada atributo', () {
        final json = {
          '_id': 'f100',
          'project_id': 'proj1',
          'user_id': 'user1',
          'active': true,
        };

        final follow = Follow.fromJson(json);

        expect(follow.id, 'f100');
        expect(follow.projectId, 'proj1');
        expect(follow.userId, 'user1');
        expect(follow.active, isTrue);
      });

      test('fromJson con id alternativo id en vez de _id', () {
        final json = {
          'id': 'f200',
          'project_id': 'proj2',
          'user_id': 'user2',
          'active': false,
        };

        final follow = Follow.fromJson(json);

        expect(follow.id, 'f200');
        expect(follow.active, isFalse);
      });

      test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
        final jsonIncompleto = <String, dynamic>{
          'active': 'false',
        };

        final follow = Follow.fromJson(jsonIncompleto);

        expect(follow.id, isNull);
        expect(follow.projectId, isEmpty);
        expect(follow.userId, isEmpty);
        expect(follow.active, isFalse);

        // Si active es null, el valor por defecto es true
        final followNullActive = Follow.fromJson(const {});
        expect(followNullActive.active, isTrue);

        // Si active viene como string 'true'
        final followStringTrue = Follow.fromJson(const {'active': 'true'});
        expect(followStringTrue.active, isTrue);
      });

      test('toJsonNoId contiene las columnas correctas sin id', () {
        final follow = Follow(
          id: 'f999',
          projectId: 'p5',
          userId: 'u5',
          active: true,
        );

        final jsonNoId = follow.toJsonNoId();

        expect(jsonNoId.containsKey('_id'), isFalse);
        expect(jsonNoId.containsKey('id'), isFalse);
        expect(jsonNoId['project_id'], 'p5');
        expect(jsonNoId['user_id'], 'u5');
        expect(jsonNoId['active'], isTrue);
      });

      test('ida y vuelta: lo que se envia en toJsonNoId vuelve igual con fromJson', () {
        final original = Follow(
          projectId: 'proj_alpha',
          userId: 'user_beta',
          active: false,
        );

        final enviado = original.toJsonNoId();
        final devuelto = Follow.fromJson(enviado);

        expect(devuelto.projectId, original.projectId);
        expect(devuelto.userId, original.userId);
        expect(devuelto.active, original.active);
      });

      test('copyWith actualiza active preservando el resto', () {
        final follow = Follow(
          id: 'f1',
          projectId: 'p1',
          userId: 'u1',
          active: true,
        );

        final inactivo = follow.copyWith(active: false);
        expect(inactivo.id, 'f1');
        expect(inactivo.projectId, 'p1');
        expect(inactivo.userId, 'u1');
        expect(inactivo.active, isFalse);
      });
    });
  });
}

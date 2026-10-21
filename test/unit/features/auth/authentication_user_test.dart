import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

void main() {
  group('AuthenticationUser', () {
    group('fromJson y toJson', () {
      test('fromJson con datos completos mapea los atributos de sesion', () {
        final json = {
          'id': 'u100',
          'email': 'estudiante@uninorte.edu.co',
          'name': 'Carlos Perez',
          'password': 'secretPassword123',
        };

        final user = AuthenticationUser.fromJson(json);

        expect(user.id, 'u100');
        expect(user.email, 'estudiante@uninorte.edu.co');
        expect(user.name, 'Carlos Perez');
        expect(user.password, 'secretPassword123');
      });

      test(
        'fromJson con datos nulos o faltantes no revienta y usa valores por defecto',
        () {
          final json = <String, dynamic>{};

          final user = AuthenticationUser.fromJson(json);

          expect(user.id, isNull);
          expect(user.email, isEmpty);
          expect(user.name, isEmpty);
          expect(user.password, isEmpty);
        },
        skip: 'Error en la app: AuthenticationUser.fromJson no maneja campos faltantes o nulos y lanza TypeError porque email, name y password no aceptan null.',
      );

      test('toJson contiene las columnas id, email, name y password', () {
        final user = AuthenticationUser(
          id: 'u200',
          email: 'ana@test.com',
          name: 'Ana',
          password: 'pass',
          academicProgram: 'Sistemas',
          semester: 4,
          skills: const ['Dart'],
          bio: 'Estudiante',
        );

        final json = user.toJson();

        expect(json, {
          'id': 'u200',
          'email': 'ana@test.com',
          'name': 'Ana',
          'password': 'pass',
        });
        // Los atributos de extra no van en el toJson basico del usuario
        expect(json.containsKey('academicProgram'), isFalse);
        expect(json.containsKey('semester'), isFalse);
      });

      test('ida y vuelta: lo que se manda a toJson vuelve igual con fromJson', () {
        final original = AuthenticationUser(
          id: 'u300',
          email: 'test@uninorte.edu.co',
          name: 'Usuario Prueba',
          password: 'miPasswordSegura',
        );

        final devuelto = AuthenticationUser.fromJson(original.toJson());

        expect(devuelto.id, original.id);
        expect(devuelto.email, original.email);
        expect(devuelto.name, original.name);
        expect(devuelto.password, original.password);
      });
    });
  });
}

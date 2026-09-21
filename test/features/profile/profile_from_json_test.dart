import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// El mapa tal y como lo devuelve `currentUser()` de Roble.
Map<String, dynamic> _respuestaDeRoble({Map<String, dynamic>? extra}) => {
      'id': 'us-3f2a-fila-del-perfil',
      'userId': '9c1e-el-usuario',
      'email': 'ana@uninorte.edu.co',
      'name': 'Ana García',
      'role': null,
      'extra': extra ??
          {
            'academicProgram': AppCatalogs.programSystems,
            'semester': 8,
            'skills': [AppCatalogs.skillPython, AppCatalogs.skillUx],
            'bio': 'Me interesa la movilidad urbana.',
          },
      'createdAt': '2026-09-01T10:00:00.000Z',
      'updatedAt': null,
    };

void main() {
  group('Profile.fromJson', () {
    test('toma userId y no id', () {
      final profile = Profile.fromJson(_respuestaDeRoble());

      // De este valor depende quien es el lider de cada proyecto: confundirlo
      // con la fila del perfil deja a todo el mundo sin sus proyectos.
      expect(profile.id, '9c1e-el-usuario');
      expect(profile.id, isNot('us-3f2a-fila-del-perfil'));
    });

    test('lee nombre, programa, semestre y habilidades del extra', () {
      final profile = Profile.fromJson(_respuestaDeRoble());

      expect(profile.fullName, 'Ana García');
      expect(profile.academicProgram, AppCatalogs.programSystems);
      expect(profile.semester, 8);
      expect(profile.skills, [AppCatalogs.skillPython, AppCatalogs.skillUx]);
      expect(profile.bio, 'Me interesa la movilidad urbana.');
      expect(profile.isComplete, isTrue);
    });

    test('la bio es opcional: sin ella el perfil sigue completo', () {
      final profile = Profile.fromJson(
        _respuestaDeRoble(
          extra: {
            'academicProgram': AppCatalogs.programSystems,
            'semester': 8,
            'skills': [AppCatalogs.skillPython],
          },
        ),
      );

      expect(profile.bio, isNull);
      expect(profile.isComplete, isTrue);
    });

    test('una bio vacia o de espacios se lee como que no hay', () {
      for (final vacia in ['', '   ']) {
        final profile = Profile.fromJson(
          _respuestaDeRoble(
            extra: {
              'academicProgram': AppCatalogs.programSystems,
              'semester': 8,
              'skills': [AppCatalogs.skillPython],
              'bio': vacia,
            },
          ),
        );

        expect(profile.bio, isNull, reason: 'bio "$vacia" deberia ser null');
      }
    });

    test('la bio se guarda sin espacios de sobra', () {
      final profile = Profile.fromJson(
        _respuestaDeRoble(
          extra: {
            'academicProgram': AppCatalogs.programSystems,
            'semester': 8,
            'skills': [AppCatalogs.skillPython],
            'bio': '  Estudio de noche.  ',
          },
        ),
      );

      expect(profile.bio, 'Estudio de noche.');
    });

    test('un extra vacio no revienta: deja el perfil incompleto', () {
      final profile = Profile.fromJson(_respuestaDeRoble(extra: const {}));

      expect(profile.id, '9c1e-el-usuario');
      expect(profile.academicProgram, isEmpty);
      expect(profile.semester, 0);
      expect(profile.skills, isEmpty);
      expect(profile.bio, isNull);
      expect(profile.isComplete, isFalse);
    });

    test('sin extra tampoco revienta', () {
      final sinExtra = _respuestaDeRoble()..remove('extra');
      final profile = Profile.fromJson(sinExtra);

      expect(profile.fullName, 'Ana García');
      expect(profile.skills, isEmpty);
    });

    test('el semestre llega como texto y se lee igual', () {
      // Roble guarda el extra tal cual se mando: si alguien lo puso como
      // texto, el perfil no puede quedarse en cero.
      final profile = Profile.fromJson(
        _respuestaDeRoble(
          extra: {
            'academicProgram': AppCatalogs.programPsychology,
            'semester': '5',
            'skills': [AppCatalogs.skillResearch],
          },
        ),
      );

      expect(profile.semester, 5);
    });

    test('role en null no es un error', () {
      expect(() => Profile.fromJson(_respuestaDeRoble()), returnsNormally);
    });
  });
}

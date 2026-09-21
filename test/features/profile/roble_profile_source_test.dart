import 'dart:convert';

import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/core/roble_config.dart';
import 'package:f_clean_template/features/profile/data/datasources/remote/roble_profile_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:roble/roble.dart';

/// Almacen en memoria: la sesion no debe tocar el llavero del sistema en una
/// prueba.
class _MemoryStorage implements RobleTokenStorage {
  final Map<String, String> _valores = {};

  @override
  Future<String?> getItem(String key) async => _valores[key];

  @override
  Future<void> setItem(String key, String value) async => _valores[key] = value;

  @override
  Future<void> removeItem(String key) async => _valores.remove(key);
}

const _perfil = {
  'id': 'us-3f2a-fila-del-perfil',
  'userId': '9c1e-el-usuario',
  'email': 'ana@uninorte.edu.co',
  'name': 'Ana García',
  'role': null,
  'extra': {
    'academicProgram': AppCatalogs.programSystems,
    'semester': 8,
    'skills': [AppCatalogs.skillPython, AppCatalogs.skillUx],
  },
  'createdAt': '2026-09-01T10:00:00.000Z',
  'updatedAt': null,
};

/// Cliente falso: responde al login con tokens y a `me` con el perfil.
MockClient _cliente({Map<String, dynamic> perfil = _perfil}) {
  return MockClient((request) async {
    final ruta = request.url.path;
    if (ruta.endsWith('/login')) {
      return http.Response(
        jsonEncode({'accessToken': 'token-de-prueba', 'refreshToken': 'r'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (ruta.endsWith('/me')) {
      return http.Response(
        jsonEncode(perfil),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('{"message":"ruta no esperada: $ruta"}', 404);
  });
}

RobleApiDataBase _roble(http.Client client) => RobleApiDataBase(
      config: RobleApiConfig.fromContract(
        baseUrl: RobleConfig.baseUrl,
        contractId: RobleConfig.contractId,
      ),
      client: client,
      storage: _MemoryStorage(),
    );

void main() {
  group('RobleProfileSource', () {
    test('sin sesion lanza en vez de devolver un perfil vacio', () async {
      final source = RobleProfileSource(_roble(_cliente()));

      // Un perfil vacio dejaria proyectos sin lider y postulaciones sin dueno.
      expect(source.getCurrentProfile(), throwsStateError);
    });

    test('con sesion devuelve el perfil de la sesion', () async {
      final roble = _roble(_cliente());
      await roble.login(email: 'ana@uninorte.edu.co', password: 'Clave12345');

      final profile = await RobleProfileSource(roble).getCurrentProfile();

      expect(profile.id, '9c1e-el-usuario');
      expect(profile.fullName, 'Ana García');
      expect(profile.academicProgram, AppCatalogs.programSystems);
      expect(profile.semester, 8);
      expect(profile.skills, [AppCatalogs.skillPython, AppCatalogs.skillUx]);
    });

    test('el id es el userId, no la fila del perfil', () async {
      final roble = _roble(_cliente());
      await roble.login(email: 'ana@uninorte.edu.co', password: 'Clave12345');

      final profile = await RobleProfileSource(roble).getCurrentProfile();

      expect(profile.id, isNot('us-3f2a-fila-del-perfil'));
    });
  });
}

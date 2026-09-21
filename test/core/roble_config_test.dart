import 'package:f_clean_template/core/roble_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';

/// `RobleApiConfig.fromContract` valida y lanza `ArgumentError` con un
/// contrato vacio, con espacios o de ejemplo. Como se construye al arrancar,
/// un valor malo en `RobleConfig` tumba la app en el primer frame sin que
/// `analyze` ni el resto de las pruebas digan nada.
void main() {
  group('RobleConfig', () {
    test('los valores reales construyen la configuracion sin lanzar', () {
      final config = RobleApiConfig.fromContract(
        baseUrl: RobleConfig.baseUrl,
        contractId: RobleConfig.contractId,
      );

      expect(config.authUrl, '${RobleConfig.baseUrl}/auth/${RobleConfig.contractId}');
      expect(config.dataUrl, '${RobleConfig.baseUrl}/database/${RobleConfig.contractId}');
    });

    test('la instancia de roble se construye con esa configuracion', () {
      final db = RobleApiDataBase(
        config: RobleApiConfig.fromContract(
          baseUrl: RobleConfig.baseUrl,
          contractId: RobleConfig.contractId,
        ),
      );

      expect(db.authState.isSignedIn, isFalse);
    });
  });
}

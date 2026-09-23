import 'dart:async';

import 'package:f_clean_template/features/auth/data/datasources/remote/roble_authentication_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';

/// Roble con el estado de sesion a mano. Como el de verdad, entrega primero
/// el estado actual a quien se suscribe y despues cada cambio.
class _RobleConSesion extends RobleApiDataBase {
  _RobleConSesion(this._actual)
    : super(
        config: RobleApiConfig.fromContract(
          baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
          contractId: 'proyecto_test_12345678',
        ),
      );

  RobleAuthState _actual;
  final _cambios = StreamController<RobleAuthState>.broadcast();

  @override
  Stream<RobleAuthState> get authStateChanges async* {
    yield _actual;
    yield* _cambios.stream;
  }

  void cambiar(RobleAuthReason motivo) {
    _actual = RobleAuthState(user: null, reason: motivo);
    _cambios.add(_actual);
  }
}

void main() {
  test('sessionChanges no repite el estado actual al suscribirse', () async {
    final roble = _RobleConSesion(
      const RobleAuthState(user: null, reason: RobleAuthReason.restored),
    );
    final avisos = <bool>[];
    final sub = RobleAuthenticationSource(
      roble,
    ).sessionChanges.listen(avisos.add);
    await Future<void>.delayed(Duration.zero);

    // Ya habia sesion: no es un cambio, y avisarlo hacia cargar dos veces.
    expect(avisos, isEmpty);

    roble.cambiar(RobleAuthReason.signedOut);
    await Future<void>.delayed(Duration.zero);
    roble.cambiar(RobleAuthReason.signedIn);
    await Future<void>.delayed(Duration.zero);

    expect(avisos, [false, true]);
    await sub.cancel();
  });
}

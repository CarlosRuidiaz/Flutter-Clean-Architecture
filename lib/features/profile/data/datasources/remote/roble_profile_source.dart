import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import '../../../domain/models/profile.dart';
import '../i_profile_source.dart';

/// El perfil del estudiante sale de la sesion de Roble, no de una tabla.
///
/// Programa, semestre y habilidades viajan en el `extra` que se mando al
/// registrarse, asi que `currentUser()` los devuelve junto al usuario.
class RobleProfileSource with UiLoggy implements IProfileSource {
  RobleProfileSource(this.roble);

  final RobleApiDataBase roble;

  @override
  Future<Profile> getCurrentProfile() async {
    loggy.debug('RobleProfileSource: pidiendo el perfil de la sesion');

    // Sin sesion no hay perfil. Devolver uno vacio dejaria proyectos sin
    // lider y postulaciones sin dueno, que es peor que fallar aqui.
    if (!roble.isLoggedIn) {
      throw StateError(
        'No hay sesion activa: no se puede resolver el perfil actual.',
      );
    }

    return Profile.fromJson(await roble.currentUser());
  }
}

import 'package:f_clean_template/features/profile/data/datasources/i_profile_source.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';

import 'fake_authentication_source.dart';

/// `IProfileSource` en memoria: el perfil es el de quien tiene la sesion abierta
/// en la fuente falsa de autenticacion.
///
/// Arma el mapa con la misma forma que `currentUser()` de Roble y lo pasa por
/// `Profile.fromJson`, asi el perfil se lee igual que en la app real: el `id`
/// sale de `userId`, y el resto del perfil, del `extra`.
class FakeProfileSource implements IProfileSource {
  FakeProfileSource(this.autenticacion);

  final FakeAuthenticationSource autenticacion;

  @override
  Future<Profile> getCurrentProfile() async {
    final cuenta = autenticacion.cuentaConSesion;

    // Sin sesion no hay perfil, como en Roble.
    if (cuenta == null) {
      throw StateError(
        'No hay sesion activa: no se puede resolver el perfil actual.',
      );
    }

    return Profile.fromJson({
      'userId': cuenta.id,
      'name': cuenta.name,
      'email': cuenta.email,
      'extra': {
        'academicProgram': cuenta.academicProgram,
        'semester': cuenta.semester,
        'skills': cuenta.skills,
        if (cuenta.bio != null) 'bio': cuenta.bio,
      },
    });
  }
}

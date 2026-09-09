import '../models/profile.dart';

/// Contrato que expone las operaciones de perfil al controlador.
///
/// La implementación concreta vive en la capa `data/` y no es visible
/// para la capa de UI.
abstract class IProfileRepository {
  Future<Profile> getCurrentProfile();
}

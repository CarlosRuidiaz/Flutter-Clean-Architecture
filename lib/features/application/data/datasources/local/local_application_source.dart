import '../../../domain/models/application.dart';
import '../i_application_source.dart';

/// Esqueleto. Los cinco metodos estan congelados por el contrato; los cuerpos
/// los llena el carril `application`.
class LocalApplicationSource implements IApplicationSource {
  @override
  Future<List<Application>> getMyApplications(String applicantId) async {
    // TODO(carril application): postulaciones quemadas del estudiante actual.
    return [];
  }

  @override
  Future<List<Application>> getApplicationsFor(String projectId) async {
    // TODO(carril management): postulaciones quemadas del proyecto.
    return [];
  }

  @override
  Future<Application> apply(Application application) async {
    // TODO(carril application): guardar y devolver la postulacion con id.
    throw UnimplementedError();
  }

  @override
  Future<void> withdraw(String applicationId) async {
    // TODO(carril application): pasar el estado a withdrawn.
  }

  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async {
    // TODO(carril management): pasar el estado a accepted o rejected.
  }
}

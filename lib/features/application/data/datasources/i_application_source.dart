import '../../domain/models/application.dart';

abstract class IApplicationSource {
  Future<List<Application>> getMyApplications(String applicantId);

  Future<List<Application>> getApplicationsFor(String projectId);

  Future<Application> apply(Application application);

  Future<void> withdraw(String applicationId);

  /// Un miembro aceptado sale del proyecto: la postulacion pasa a `left`.
  Future<void> leave(String applicationId);

  Future<void> decide(String applicationId, ApplicationStatus decision);
}

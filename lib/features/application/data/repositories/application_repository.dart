import '../../domain/models/application.dart';
import '../../domain/repositories/i_application_repository.dart';
import '../datasources/i_application_source.dart';

/// Delega en la fuente, igual que `ProjectRepository`.
///
/// Aqui, y no en la fuente, entrara mas adelante la decision "¿red o cache?".
class ApplicationRepository implements IApplicationRepository {
  ApplicationRepository(this.source);

  final IApplicationSource source;

  @override
  Future<List<Application>> getMyApplications(String applicantId) async =>
      await source.getMyApplications(applicantId);

  @override
  Future<List<Application>> getApplicationsFor(String projectId) async =>
      await source.getApplicationsFor(projectId);

  @override
  Future<Application> apply(Application application) async =>
      await source.apply(application);

  @override
  Future<void> withdraw(String applicationId) async =>
      await source.withdraw(applicationId);

  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async =>
      await source.decide(applicationId, decision);
}

import '../models/application.dart';

abstract class IApplicationRepository {
  Future<List<Application>> getMyApplications(String applicantId);

  Future<List<Application>> getApplicationsFor(String projectId);

  Future<Application> apply(Application application);

  Future<void> withdraw(String applicationId);

  Future<void> decide(String applicationId, ApplicationStatus decision);
}

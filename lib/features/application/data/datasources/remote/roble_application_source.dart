import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import '../../../domain/models/application.dart';
import '../i_application_source.dart';

class RobleApplicationSource with UiLoggy implements IApplicationSource {
  final RobleApiDataBase roble;

  RobleApplicationSource(this.roble);

  @override
  Future<List<Application>> getMyApplications(String applicantId) async {
    loggy.debug(
      'RobleApplicationSource.getMyApplications: consultando para estudiante $applicantId',
    );
    final records = await roble.read(
      'applications',
      filters: {'applicant_id': applicantId},
    );
    return records.map(Application.fromJson).toList();
  }

  @override
  Future<List<Application>> getApplicationsFor(String projectId) async {
    loggy.debug(
      'RobleApplicationSource.getApplicationsFor: consultando para proyecto $projectId',
    );
    final records = await roble.read(
      'applications',
      filters: {'project_id': projectId},
    );
    return records.map(Application.fromJson).toList();
  }

  @override
  Future<Application> apply(Application application) async {
    loggy.debug(
      'RobleApplicationSource.apply: postulando estudiante ${application.applicantId} a proyecto ${application.projectId}',
    );
    final records = await roble.read(
      'applications',
      filters: {
        'project_id': application.projectId,
        'applicant_id': application.applicantId,
      },
    );
    final apps = records.map(Application.fromJson);
    for (final app in apps) {
      if (app.projectId == application.projectId &&
          app.applicantId == application.applicantId &&
          (app.status == ApplicationStatus.pending ||
              app.status == ApplicationStatus.accepted)) {
        return app;
      }
    }

    final created = await roble.create(
      'applications',
      application.toJsonNoId(),
    );
    return Application.fromJson(created);
  }

  @override
  Future<void> withdraw(String applicationId) async {
    loggy.debug(
      'RobleApplicationSource.withdraw: retirando postulacion $applicationId',
    );
    await roble.update('applications', applicationId, {
      'status': ApplicationStatus.withdrawn.name,
    });
  }

  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async {
    loggy.debug(
      'RobleApplicationSource.decide: actualizando estado de $applicationId a ${decision.name}',
    );
    await roble.update('applications', applicationId, {
      'status': decision.name,
    });
  }
}

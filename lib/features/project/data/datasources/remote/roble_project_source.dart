import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import '../../../domain/models/project.dart';
import '../i_project_source.dart';

class RobleProjectSource with UiLoggy implements IProjectSource {
  final RobleApiDataBase roble;

  RobleProjectSource(this.roble);

  @override
  Future<List<Project>> getProjects() async {
    loggy.debug('RobleProjectSource.getProjects: consultando tabla projects');
    final records = await roble.read('projects');
    return records.map(Project.fromJson).toList();
  }

  @override
  Future<Project> createProject(Project project) async {
    loggy.debug('RobleProjectSource.createProject: insertando en projects');
    final record = await roble.create('projects', project.toJsonNoId());
    return Project.fromJson(record);
  }

  @override
  Future<void> closeRecruitment(String projectId) async {
    loggy.debug(
      'RobleProjectSource.closeRecruitment: cerrando reclutamiento de $projectId',
    );
    await roble.update('projects', projectId, {'recruitment_open': false});
  }

  @override
  Future<void> addMember(String projectId) async {
    loggy.debug('RobleProjectSource.addMember: sumando miembro a $projectId');
    final record = await roble.getById('projects', projectId);
    if (record == null) return;
    final project = Project.fromJson(record);
    if (!project.isFull) {
      await roble.update('projects', projectId, {
        'current_members': project.currentMembers + 1,
      });
    }
  }
}

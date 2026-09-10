import '../../../domain/models/project.dart';
import '../i_project_source.dart';

class LocalProjectSource implements IProjectSource {
  @override
  Future<List<Project>> getProjects() async {
    return [
      Project(
        id: '1',
        title: 'App de movilidad sostenible',
        stage: ProjectStage.research,
        academicProgram: 'Ingeniería Civil',
        currentMembers: 4,
        maxMembers: 6,
        skillsWanted: ['Análisis de datos', 'Diseño UX'],
      ),
      Project(
        id: '2',
        title: 'Plataforma de tutorías entre pares',
        stage: ProjectStage.idea,
        academicProgram: 'Ingeniería de Sistemas',
        currentMembers: 2,
        maxMembers: 4,
        skillsWanted: ['Flutter', 'Backend'],
      ),
      Project(
        id: '3',
        title: 'Dispositivo IoT para monitoreo de agua',
        stage: ProjectStage.prototype,
        academicProgram: 'Ingeniería Electrónica',
        currentMembers: 3,
        maxMembers: 5,
        skillsWanted: ['Hardware', 'IoT', 'C++'],
      ),
      Project(
        id: '4',
        title: 'Red comunitaria de reciclaje textil',
        stage: ProjectStage.teamFormation,
        academicProgram: 'Diseño Industrial',
        currentMembers: 5,
        maxMembers: 5,
        skillsWanted: ['Logística', 'Marketing'],
      ),
      Project(
        id: '5',
        title: 'Sistema de alertas para emergencias en campus',
        stage: ProjectStage.testing,
        academicProgram: 'Enfermería',
        currentMembers: 2,
        maxMembers: 4,
        skillsWanted: [],
      ),
      Project(
        id: '6',
        title: 'Biblioteca digital accesible',
        stage: ProjectStage.finished,
        academicProgram: 'Psicología',
        currentMembers: 3,
        maxMembers: 4,
        skillsWanted: ['Accesibilidad'],
      ),
    ];
  }
}

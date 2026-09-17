import '../../../../../core/app_catalogs.dart';
import '../../../domain/models/project.dart';
import '../i_project_source.dart';

class LocalProjectSource implements IProjectSource {
  final List<Project> _projects = [
    Project(
      id: '1',
      title: 'App de movilidad sostenible',
      problem:
          'Los estudiantes que viven lejos del campus pierden hasta dos horas '
          'diarias en transporte y no tienen forma de coordinarse entre ellos.',
      description:
          'Una app que arma rutas compartidas entre estudiantes que salen del '
          'mismo sector a la misma hora, con estimacion de huella de carbono.',
      stage: ProjectStage.research,
      academicProgram: AppCatalogs.programArchitecture,
      currentMembers: 4,
      maxMembers: 6,
      skillsWanted: [AppCatalogs.skillData, AppCatalogs.skillUx],
      tags: [AppCatalogs.tagSustainability, AppCatalogs.tagTechnology],
      leaderId: 'u3',
    ),
    Project(
      id: '2',
      title: 'Plataforma de tutorías entre pares',
      problem:
          'Las materias de primer semestre tienen alta deserción y las monitorías '
          'oficiales no alcanzan para todos los que las piden.',
      description:
          'Un espacio donde un estudiante de semestres avanzados ofrece tutorías '
          'en una materia y quien la necesita reserva un horario.',
      stage: ProjectStage.idea,
      academicProgram: AppCatalogs.programSystems,
      currentMembers: 2,
      maxMembers: 4,
      skillsWanted: [AppCatalogs.skillWeb, AppCatalogs.skillManagement],
      tags: [AppCatalogs.tagEducation, AppCatalogs.tagTutoring],
      leaderId: '1', // el perfil actual: por eso puede abrir la pantalla 18
    ),
    Project(
      id: '3',
      title: 'Dispositivo IoT para monitoreo de agua',
      problem:
          'Los laboratorios no saben si el agua de los tanques cumple los '
          'parámetros hasta que llega el informe de laboratorio, una semana después.',
      description:
          'Un sensor de bajo costo que mide pH y turbidez cada hora y publica la '
          'lectura en un tablero que cualquiera puede consultar.',
      stage: ProjectStage.prototype,
      academicProgram: AppCatalogs.programSystems,
      currentMembers: 3,
      maxMembers: 5,
      skillsWanted: [AppCatalogs.skillPython, AppCatalogs.skillData],
      tags: [AppCatalogs.tagTechnology, AppCatalogs.tagSocial],
      leaderId: 'u5',
    ),
    Project(
      id: '4',
      title: 'Red comunitaria de reciclaje textil',
      problem:
          'La ropa que los estudiantes dejan de usar termina en la basura porque '
          'no hay un punto de acopio ni quien la redistribuya.',
      description:
          'Una red de puntos de acopio en el campus con un inventario compartido '
          'y jornadas de intercambio cada mes.',
      stage: ProjectStage.teamFormation,
      academicProgram: AppCatalogs.programIndustrialDesign,
      currentMembers: 5,
      maxMembers: 5, // equipo lleno: isFull y acceptsApplications en false
      skillsWanted: [AppCatalogs.skillManagement, AppCatalogs.skillMarketing],
      tags: [AppCatalogs.tagSustainability, AppCatalogs.tagCommunity],
      leaderId: 'u2',
    ),
    Project(
      id: '5',
      title: 'Sistema de alertas para emergencias en campus',
      problem:
          'Ante una emergencia no hay un canal único: la información llega tarde, '
          'por WhatsApp y sin instrucciones claras.',
      description:
          'Una alerta que llega al celular con el tipo de emergencia, el punto de '
          'encuentro y la ruta de evacuación más cercana.',
      stage: ProjectStage.testing,
      academicProgram: AppCatalogs.programBusiness,
      currentMembers: 2,
      maxMembers: 4,
      skillsWanted: [], // sin habilidades pedidas: la tarjeta no pinta la linea
      tags: [AppCatalogs.tagSocial],
      leaderId: 'u4',
    ),
    Project(
      id: '6',
      title: 'Biblioteca digital accesible',
      problem:
          'Los estudiantes con baja visión no pueden usar el repositorio de la '
          'universidad: los PDF escaneados no los lee ningún lector de pantalla.',
      description:
          'Un catálogo con los textos convertidos a formato accesible, navegable '
          'por voz y con contraste ajustable.',
      stage: ProjectStage.finished,
      academicProgram: AppCatalogs.programPsychology,
      currentMembers: 3,
      maxMembers: 4,
      skillsWanted: [AppCatalogs.skillUx, AppCatalogs.skillResearch],
      tags: [AppCatalogs.tagEducation, AppCatalogs.tagSocial],
      leaderId: 'u6',
      recruitmentOpen: false, // proyecto terminado: ya no recibe postulaciones
    ),
  ];

  int _nextId = 7;

  @override
  Future<List<Project>> getProjects() async => List.unmodifiable(_projects);

  @override
  Future<Project> createProject(Project project) async {
    final creado = Project(
      id: '${_nextId++}',
      title: project.title,
      problem: project.problem,
      description: project.description,
      stage: project.stage,
      academicProgram: project.academicProgram,
      currentMembers: project.currentMembers,
      maxMembers: project.maxMembers,
      skillsWanted: project.skillsWanted,
      tags: project.tags,
      leaderId: project.leaderId,
      recruitmentOpen: project.recruitmentOpen,
    );
    _projects.insert(0, creado);
    return creado;
  }

  @override
  Future<void> closeRecruitment(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(recruitmentOpen: false);
    }
  }

  @override
  Future<void> addMember(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index == -1) return;

    final actual = _projects[index];
    // Un equipo lleno no crece: maxMembers es el tope y nadie lo pasa.
    if (actual.isFull) return;
    _projects[index] = actual.copyWith(
      currentMembers: actual.currentMembers + 1,
    );
  }
}

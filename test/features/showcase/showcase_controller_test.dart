import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/showcase/data/datasources/local/local_showcase_source.dart';
import 'package:f_clean_template/features/showcase/data/repositories/showcase_repository.dart';
import 'package:f_clean_template/features/showcase/ui/viewmodels/showcase_controller.dart';

import '../auth/fake_auth_repository.dart';

class _FakeProjectRepository implements IProjectRepository {
  _FakeProjectRepository(this.projects);
  final List<Project> projects;

  @override
  Future<List<Project>> getProjects() async => projects;
  @override
  Future<Project> createProject(Project project) async => project;
  @override
  Future<void> closeRecruitment(String projectId) async {}
  @override
  Future<void> addMember(String projectId) async {}
  @override
  Future<void> removeMember(String projectId) async {}
  @override
  Future<void> updateStage(String projectId, ProjectStage stage) async {}
}

class _FakeProfileRepository implements IProfileRepository {
  _FakeProfileRepository(this.profile);
  Profile? profile;

  @override
  Future<Profile> getCurrentProfile() async => profile!;
}

class _FakeApplicationRepository implements IApplicationRepository {
  _FakeApplicationRepository(this.applications);
  final List<Application> applications;

  @override
  Future<List<Application>> getMyApplications(String applicantId) async => [];
  @override
  Future<List<Application>> getApplicationsFor(String projectId) async =>
      applications.where((a) => a.projectId == projectId).toList();
  @override
  Future<Application> apply(Application application) async => application;
  @override
  Future<void> withdraw(String applicationId) async {}
  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async {}
  @override
  Future<void> leave(String applicationId) async {}
}

void main() {
  group('ShowcaseController - Reglas de negocio y permisos', () {
    late _FakeProjectRepository projectRepo;
    late ShowcaseRepository showcaseRepo;
    late _FakeProfileRepository profileRepo;
    late _FakeApplicationRepository applicationRepo;
    late ShowcaseController controller;
    late FakeAuthRepository authRepo;

    final prototypeProject = Project(
      id: 'proto_1',
      title: 'App de movilidad sostenible',
      problem: 'Movilidad en campus',
      description: 'Prototipo navegable',
      stage: ProjectStage.prototype,
      academicProgram: 'Diseño Industrial',
      currentMembers: 3,
      maxMembers: 5,
      skillsWanted: ['UX'],
      leaderId: 'leader_1',
    );

    final ideaProject = Project(
      id: 'idea_1',
      title: 'Red de tutorías',
      problem: 'Tutorías',
      description: 'Idea de tutorías',
      stage: ProjectStage.idea,
      academicProgram: 'Sistemas',
      currentMembers: 1,
      maxMembers: 4,
      skillsWanted: ['Dart'],
      leaderId: 'other_user',
    );

    setUp(() {
      projectRepo = _FakeProjectRepository([prototypeProject, ideaProject]);
      showcaseRepo = ShowcaseRepository(LocalShowcaseSource());
      profileRepo = _FakeProfileRepository(
        Profile(
          id: 'student_1',
          fullName: 'Laura Peñaloza',
          academicProgram: 'Psicología',
          semester: 6,
          skills: [],
        ),
      );
      applicationRepo = _FakeApplicationRepository([]);

      authRepo = FakeAuthRepository();
      controller = ShowcaseController(
        projectRepo,
        showcaseRepo,
        profileRepo,
        applicationRepo,
        authRepo,
      );
    });

    test('1 · La vitrina muestra solo proyectos en etapa Prototype', () async {
      await controller.loadPrototypeProjects();
      expect(controller.prototypeProjects.length, 1);
      expect(controller.prototypeProjects.first.id, 'proto_1');
      expect(controller.prototypeProjects.first.stage, ProjectStage.prototype);
    });

    test('2 · El líder y miembros aceptados son identificados como equipo',
        () async {
      // Caso estudiante externo
      await controller.openProject(prototypeProject);
      expect(controller.isTeamMember.value, isFalse);

      // Caso líder
      profileRepo.profile = Profile(
        id: 'leader_1',
        fullName: 'Líder',
        academicProgram: 'Diseño',
        semester: 8,
        skills: [],
      );
      await controller.openProject(prototypeProject);
      expect(controller.isTeamMember.value, isTrue);

      // Caso miembro aceptado
      profileRepo.profile = Profile(
        id: 'member_accepted',
        fullName: 'Miembro',
        academicProgram: 'Sistemas',
        semester: 7,
        skills: [],
      );
      applicationRepo.applications.add(
        Application(
          id: 'app_1',
          projectId: 'proto_1',
          applicantId: 'member_accepted',
          applicantName: 'Miembro',
          applicantProgram: 'Sistemas',
          applicantSemester: 7,
          skillsOffered: [],
          status: ApplicationStatus.accepted,
        ),
      );
      await controller.openProject(prototypeProject);
      expect(controller.isTeamMember.value, isTrue);
    });

    test('3 · Solo el equipo puede responder y las respuestas quedan asociadas',
        () async {
      // Estudiante externo crea un comentario raíz
      profileRepo.profile = Profile(
        id: 'student_1',
        fullName: 'Laura',
        academicProgram: 'Psicología',
        semester: 6,
        skills: [],
      );
      await controller.openProject(prototypeProject);
      final comento = await controller.addComment('¿Cómo funciona el cupo?');
      expect(comento, isTrue);
      expect(controller.rootComments.length, 1);
      final root = controller.rootComments.first;

      // Estudiante externo intenta responder: debe ser rechazado
      final respuestaExterna = await controller.addComment(
        'Intento externo de responder',
        parentId: root.id,
      );
      expect(respuestaExterna, isFalse);

      // Líder (equipo) responde
      profileRepo.profile = Profile(
        id: 'leader_1',
        fullName: 'Líder del proyecto',
        academicProgram: 'Diseño',
        semester: 8,
        skills: [],
      );
      await controller.openProject(prototypeProject);
      final respuestaLider = await controller.addComment(
        'El conductor confirma antes de reservar.',
        parentId: root.id,
      );
      expect(respuestaLider, isTrue);

      // Verificar que la respuesta quedó asociada bajo el comentario raíz
      final respuestas = controller.repliesFor(root.id!);
      expect(respuestas.length, 1);
      expect(respuestas.first.text, 'El conductor confirma antes de reservar.');
      expect(respuestas.first.isTeam, isTrue);
      expect(respuestas.first.parentId, root.id);
    });

    test('4 · El equipo no puede calificar su propio proyecto', () async {
      profileRepo.profile = Profile(
        id: 'leader_1',
        fullName: 'Líder',
        academicProgram: 'Diseño',
        semester: 8,
        skills: [],
      );
      await controller.openProject(prototypeProject);
      expect(controller.isTeamMember.value, isTrue);

      final pudoEnviar = await controller.submitFeedback(
        usability: 5,
        innovation: 5,
        visualDesign: 5,
        feasibility: 5,
      );
      expect(pudoEnviar, isFalse);
      expect(controller.feedbackList, isEmpty);
    });

    test(
        '5 · Un segundo feedback del mismo estudiante actualiza el primero',
        () async {
      profileRepo.profile = Profile(
        id: 'student_1',
        fullName: 'Laura',
        academicProgram: 'Psicología',
        semester: 6,
        skills: [],
      );
      await controller.openProject(prototypeProject);

      final envio1 = await controller.submitFeedback(
        usability: 3,
        innovation: 3,
        visualDesign: 3,
        feasibility: 3,
        comment: 'Primer intento',
      );
      expect(envio1, isTrue);
      expect(controller.feedbackList.length, 1);
      expect(controller.feedbackSummary.overallAverage, 3.0);

      // Segundo envío: actualiza
      final envio2 = await controller.submitFeedback(
        usability: 5,
        innovation: 5,
        visualDesign: 5,
        feasibility: 5,
        comment: 'Segundo intento mejorado',
      );
      expect(envio2, isTrue);
      expect(controller.feedbackList.length, 1);
      expect(controller.feedbackSummary.overallAverage, 5.0);
      expect(controller.myFeedback?.comment, 'Segundo intento mejorado');
    });

    test('6 · Los promedios del resumen son correctos sin ningún feedback',
        () async {
      await controller.openProject(prototypeProject);
      expect(controller.feedbackList, isEmpty);
      expect(controller.feedbackSummary.isEmpty, isTrue);
      expect(controller.feedbackSummary.totalCount, 0);
      expect(controller.feedbackSummary.overallAverage, 0.0);
    });

    test('7 · cerrar sesion vacia el perfil, el equipo y el feedback',
        () async {
      profileRepo.profile = Profile(
        id: 'leader_1',
        fullName: 'Líder',
        academicProgram: 'Diseño',
        semester: 8,
        skills: [],
      );
      controller.onInit();
      await controller.openProject(prototypeProject);
      expect(controller.currentProfile.value?.id, 'leader_1');
      expect(controller.isTeamMember.value, isTrue);

      authRepo.emitirSesion(false);
      await Future<void>.delayed(Duration.zero);

      // La cuenta siguiente no hereda nada de quien salio.
      expect(controller.currentProfile.value, isNull);
      expect(controller.isTeamMember.value, isFalse);
      expect(controller.myFeedback, isNull);
      expect(controller.comments, isEmpty);
      controller.onClose();
      await authRepo.cerrar();
    });
  });
}

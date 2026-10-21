import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/poll/domain/models/poll.dart';
import 'package:f_clean_template/features/poll/domain/models/poll_response.dart';
import 'package:f_clean_template/features/poll/domain/repositories/i_poll_repository.dart';
import 'package:f_clean_template/features/poll/ui/viewmodels/poll_controller.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';

import '../auth/fake_auth_repository.dart';

class _FakePollRepository implements IPollRepository {
  final List<Poll> polls = [];
  final List<PollResponse> responses = [];
  bool shouldThrow = false;

  @override
  Future<List<Poll>> getPollsForProject(String projectId) async {
    if (shouldThrow) throw Exception('Error cargando encuestas');
    return polls.where((p) => p.projectId == projectId).toList();
  }

  @override
  Future<Poll> createPoll(Poll poll) async {
    if (shouldThrow) throw Exception('Error creando encuesta');
    final creada = Poll(
      id: 'poll_${polls.length + 1}',
      projectId: poll.projectId,
      authorId: poll.authorId,
      title: poll.title,
      description: poll.description,
      questions: poll.questions,
      closesAt: poll.closesAt,
      audienceProgram: poll.audienceProgram,
    );
    polls.add(creada);
    return creada;
  }

  @override
  Future<List<PollResponse>> getResponsesForPoll(String pollId) async {
    if (shouldThrow) throw Exception('Error cargando respuestas');
    return responses.where((r) => r.pollId == pollId).toList();
  }

  @override
  Future<PollResponse> createResponse(PollResponse response) async {
    if (shouldThrow) throw Exception('Error guardando respuesta');
    final creada = PollResponse(
      id: 'resp_${responses.length + 1}',
      pollId: response.pollId,
      respondentId: response.respondentId,
      answers: response.answers,
      comment: response.comment,
    );
    responses.add(creada);
    return creada;
  }
}

class _FakeAuthRepoWithUser extends FakeAuthRepository {
  AuthenticationUser? currentUser;

  @override
  Future<AuthenticationUser?> getLoggedUser() async => currentUser;
}

class _FakeProfileRepo implements IProfileRepository {
  Profile currentProfile = Profile(
    id: 'u1',
    fullName: 'Ana Perez',
    academicProgram: 'Ingenieria de Sistemas',
    semester: 6,
    skills: ['Flutter'],
  );

  @override
  Future<Profile> getCurrentProfile() async => currentProfile;
}

class _FakeProjectRepo implements IProjectRepository {
  final List<Project> projects = [];

  @override
  Future<List<Project>> getProjects() async => projects;

  @override
  Future<Project> createProject(Project project) async => throw UnimplementedError();
  @override
  Future<void> closeRecruitment(String projectId) async => throw UnimplementedError();
  @override
  Future<void> addMember(String projectId) async => throw UnimplementedError();
  @override
  Future<void> removeMember(String projectId) async => throw UnimplementedError();
  @override
  Future<void> updateStage(String projectId, ProjectStage stage) async => throw UnimplementedError();
}

class _FakeAppRepo implements IApplicationRepository {
  final List<Application> applications = [];

  @override
  Future<List<Application>> getApplicationsFor(String projectId) async =>
      applications.where((a) => a.projectId == projectId).toList();

  @override
  Future<List<Application>> getMyApplications(String applicantId) async =>
      applications.where((a) => a.applicantId == applicantId).toList();

  @override
  Future<Application> apply(Application application) async => throw UnimplementedError();
  @override
  Future<void> withdraw(String applicationId) async => throw UnimplementedError();
  @override
  Future<void> leave(String applicationId) async => throw UnimplementedError();
  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async => throw UnimplementedError();
}

void main() {
  group('PollController', () {
    late _FakePollRepository pollRepo;
    late _FakeAuthRepoWithUser authRepo;
    late _FakeProfileRepo profileRepo;
    late _FakeProjectRepo projectRepo;
    late _FakeAppRepo appRepo;
    late PollController controller;

    setUp(() {
      pollRepo = _FakePollRepository();
      authRepo = _FakeAuthRepoWithUser();
      profileRepo = _FakeProfileRepo();
      projectRepo = _FakeProjectRepo();
      appRepo = _FakeAppRepo();

      controller = PollController(
        pollRepo,
        authRepo,
        profileRepo,
        projectRepo,
        appRepo,
      );
    });

    test('loadPollsForProject carga encuestas y respuestas asociadas', () async {
      pollRepo.polls.add(Poll(
        id: 'p1',
        projectId: 'proj1',
        authorId: 'u1',
        title: 'Encuesta 1',
        description: '',
        questions: const [],
        closesAt: DateTime.now().add(const Duration(days: 2)),
      ));
      pollRepo.responses.add(PollResponse(
        id: 'r1',
        pollId: 'p1',
        respondentId: 'u2',
        answers: const [0],
      ));

      await controller.loadPollsForProject('proj1');

      expect(controller.projectPolls['proj1']?.length, 1);
      expect(controller.pollResponses['p1']?.length, 1);
      expect(controller.isLoading.value, isFalse);
    });

    test('isLoading vuelve a false cuando el repositorio falla en loadPollsForProject', () async {
      pollRepo.shouldThrow = true;

      await controller.loadPollsForProject('proj1');

      expect(controller.isLoading.value, isFalse);
      expect(controller.projectPolls['proj1'], isNull);
    });

    test('createPoll agrega la encuesta al mapa y apaga isLoading', () async {
      final poll = Poll(
        projectId: 'proj1',
        authorId: 'u1',
        title: 'Nueva Encuesta',
        description: 'Desc',
        questions: const [],
        closesAt: DateTime.now().add(const Duration(days: 3)),
      );

      final creada = await controller.createPoll(poll);

      expect(creada, isNotNull);
      expect(controller.projectPolls['proj1']?.length, 1);
      expect(controller.projectPolls['proj1']?.first.title, 'Nueva Encuesta');
      expect(controller.isLoading.value, isFalse);
    });

    test('createPoll devuelve null y apaga isLoading cuando falla el repositorio', () async {
      pollRepo.shouldThrow = true;

      final poll = Poll(
        projectId: 'proj1',
        authorId: 'u1',
        title: 'Falla',
        description: '',
        questions: const [],
        closesAt: DateTime.now().add(const Duration(days: 1)),
      );

      final resultado = await controller.createPoll(poll);

      expect(resultado, isNull);
      expect(controller.isLoading.value, isFalse);
    });

    test('respondPoll guarda respuesta, actualiza mapa y apaga isLoading', () async {
      final resp = PollResponse(
        pollId: 'poll_1',
        respondentId: 'u2',
        answers: const [1],
      );

      final creada = await controller.respondPoll(resp);

      expect(creada, isNotNull);
      expect(controller.pollResponses['poll_1']?.length, 1);
      expect(controller.isLoading.value, isFalse);
    });

    group('reglas de respuesta (canRespond)', () {
      final pollActiva = Poll(
        id: 'poll_1',
        projectId: 'proj1',
        authorId: 'lider',
        title: 'Encuesta Activa',
        description: '',
        questions: const [],
        closesAt: DateTime.now().add(const Duration(days: 5)),
        audienceProgram: 'Ingenieria de Sistemas',
      );

      test('permite responder si esta activa, dentro de la audiencia y no ha respondido', () async {
        authRepo.currentUser = AuthenticationUser(
          id: 'u1',
          email: 'u1@test.com',
          name: 'Ana',
          password: '',
        );
        profileRepo.currentProfile = Profile(
          id: 'u1',
          fullName: 'Ana',
          academicProgram: 'Ingenieria de Sistemas',
          semester: 5,
          skills: [],
        );

        expect(await controller.canRespond(pollActiva), isTrue);
      });

      test('rechaza si la encuesta ya esta cerrada', () async {
        authRepo.currentUser = AuthenticationUser(
          id: 'u1',
          email: 'u1@test.com',
          name: 'Ana',
          password: '',
        );
        final pollCerrada = Poll(
          id: 'poll_cerrada',
          projectId: 'proj1',
          authorId: 'lider',
          title: 'Cerrada',
          description: '',
          questions: const [],
          closesAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(await controller.canRespond(pollCerrada), isFalse);
      });

      test('rechaza si el usuario ya respondio la encuesta (no responder dos veces)', () async {
        authRepo.currentUser = AuthenticationUser(
          id: 'u1',
          email: 'u1@test.com',
          name: 'Ana',
          password: '',
        );
        controller.pollResponses['poll_1'] = [
          PollResponse(
            id: 'r1',
            pollId: 'poll_1',
            respondentId: 'u1',
            answers: const [0],
          ),
        ];

        expect(await controller.canRespond(pollActiva), isFalse);
      });

      test('rechaza si el estudiante esta fuera de la audiencia', () async {
        authRepo.currentUser = AuthenticationUser(
          id: 'u2',
          email: 'u2@test.com',
          name: 'Carlos',
          password: '',
        );
        profileRepo.currentProfile = Profile(
          id: 'u2',
          fullName: 'Carlos',
          academicProgram: 'Medicina',
          semester: 2,
          skills: [],
        );

        expect(await controller.canRespond(pollActiva), isFalse);
      });

      test('rechaza si no hay sesion iniciada', () async {
        authRepo.currentUser = null;
        expect(await controller.canRespond(pollActiva), isFalse);
      });
    });

    group('reglas de visualizacion de resultados (canViewResults)', () {
      test('cualquiera puede ver resultados si la encuesta ya cerro', () async {
        final pollCerrada = Poll(
          id: 'p_cerrada',
          projectId: 'proj1',
          authorId: 'u9',
          title: 'Cerrada',
          description: '',
          questions: const [],
          closesAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        expect(await controller.canViewResults(pollCerrada), isTrue);
      });

      test('quien respondio puede ver resultados aun estando activa', () async {
        final poll = Poll(
          id: 'p_activa',
          projectId: 'proj1',
          authorId: 'lider1',
          title: 'Activa',
          description: '',
          questions: const [],
          closesAt: DateTime.now().add(const Duration(days: 1)),
        );
        authRepo.currentUser = AuthenticationUser(
          id: 'u1',
          email: 'u1@test.com',
          name: 'Ana',
          password: '',
        );
        controller.pollResponses['p_activa'] = [
          PollResponse(id: 'r1', pollId: 'p_activa', respondentId: 'u1', answers: const [0]),
        ];

        expect(await controller.canViewResults(poll), isTrue);
      });

      test('el lider del proyecto puede ver resultados de su encuesta activa', () async {
        final poll = Poll(
          id: 'p_activa',
          projectId: 'proj1',
          authorId: 'lider1',
          title: 'Activa',
          description: '',
          questions: const [],
          closesAt: DateTime.now().add(const Duration(days: 1)),
        );
        authRepo.currentUser = AuthenticationUser(
          id: 'lider1',
          email: 'lider@test.com',
          name: 'Lider',
          password: '',
        );
        projectRepo.projects.add(Project(
          id: 'proj1',
          title: 'Proyecto 1',
          problem: '',
          description: '',
          stage: ProjectStage.idea,
          academicProgram: '',
          currentMembers: 1,
          maxMembers: 4,
          skillsWanted: const [],
          leaderId: 'lider1',
        ));

        expect(await controller.canViewResults(poll), isTrue);
      });
    });
  });
}

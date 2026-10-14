import 'dart:async';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../application/domain/models/application.dart';
import '../../../application/domain/repositories/i_application_repository.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/domain/repositories/i_project_repository.dart';
import '../../domain/models/feedback_summary.dart';
import '../../domain/models/project_comment.dart';
import '../../domain/models/project_feedback.dart';
import '../../domain/repositories/i_showcase_repository.dart';

class ShowcaseController extends GetxController with UiLoggy {
  ShowcaseController(
    this.projectRepository,
    this.showcaseRepository,
    this.profileRepository,
    this.applicationRepository,
    this.authRepository,
  );

  final IProjectRepository projectRepository;
  final IShowcaseRepository showcaseRepository;
  final IProfileRepository profileRepository;
  final IApplicationRepository applicationRepository;
  final IAuthRepository authRepository;

  StreamSubscription<bool>? _sesion;

  // Vitrina
  final RxList<Project> prototypeProjects = <Project>[].obs;
  final RxBool isLoadingShowcase = false.obs;
  final RxString showcaseError = ''.obs;

  final RxMap<String, int> commentCounts = <String, int>{}.obs;
  final RxMap<String, double> feedbackAverages = <String, double>{}.obs;
  final RxMap<String, int> feedbackCounts = <String, int>{}.obs;

  // Prototipo actual
  final Rxn<Project> currentProject = Rxn<Project>();
  final Rxn<Profile> currentProfile = Rxn<Profile>();
  final RxBool isTeamMember = false.obs;
  final RxList<ProjectComment> comments = <ProjectComment>[].obs;
  final RxList<ProjectFeedback> feedbackList = <ProjectFeedback>[].obs;
  final RxBool isLoadingDetail = false.obs;
  final RxString detailError = ''.obs;

  FeedbackSummary get feedbackSummary => FeedbackSummary.fromList(feedbackList);

  ProjectFeedback? get myFeedback {
    final me = currentProfile.value?.id;
    if (me == null || me.isEmpty) return null;
    try {
      return feedbackList.firstWhere((f) => f.authorId == me);
    } catch (_) {
      return null;
    }
  }

  /// Comentarios raíz ordenados del más nuevo al más viejo.
  List<ProjectComment> get rootComments {
    final roots = comments
        .where((c) => c.parentId == null || c.parentId!.isEmpty)
        .toList();
    roots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return roots;
  }

  /// Respuestas a un comentario raíz ordenadas cronológicamente.
  List<ProjectComment> repliesFor(String parentId) {
    final reps = comments.where((c) => c.parentId == parentId).toList();
    reps.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return reps;
  }

  @override
  void onInit() {
    loadPrototypeProjects();
    // El perfil, si es del equipo y "mi feedback" son de quien tenga la
    // sesion: sin esto la cuenta siguiente los veia mientras cargaba el suyo.
    _sesion = authRepository.sessionChanges.listen((haySesion) {
      loggy.debug('ShowcaseController: cambio de sesion (activa: $haySesion)');
      if (haySesion) {
        loadPrototypeProjects();
      } else {
        _vaciarDelUsuario();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    _sesion?.cancel();
    super.onClose();
  }

  void _vaciarDelUsuario() {
    currentProject.value = null;
    currentProfile.value = null;
    isTeamMember.value = false;
    comments.clear();
    feedbackList.clear();
  }

  Future<void> loadPrototypeProjects() async {
    loggy.debug('ShowcaseController.loadPrototypeProjects');
    if (prototypeProjects.isEmpty) {
      isLoadingShowcase.value = true;
    }
    showcaseError.value = '';

    try {
      final all = await projectRepository.getProjects();
      final prototypes =
          all.where((p) => p.stage == ProjectStage.prototype).toList();
      prototypeProjects.value = prototypes;

      for (final p in prototypes) {
        final pid = p.id;
        if (pid != null && pid.isNotEmpty) {
          _loadStatsFor(pid);
        }
      }
    } catch (e) {
      loggy.error('Error cargando prototipos: $e');
      showcaseError.value = 'No se pudieron cargar los prototipos.';
    } finally {
      isLoadingShowcase.value = false;
    }
  }

  Future<void> _loadStatsFor(String projectId) async {
    try {
      final cList = await showcaseRepository.getComments(projectId);
      final fList = await showcaseRepository.getFeedback(projectId);
      commentCounts[projectId] = cList.length;
      final summary = FeedbackSummary.fromList(fList);
      feedbackAverages[projectId] = summary.overallAverage;
      feedbackCounts[projectId] = summary.totalCount;
    } catch (_) {}
  }

  Future<void> openProject(Project project) async {
    currentProject.value = project;
    detailError.value = '';
    if (comments.isEmpty && feedbackList.isEmpty) {
      isLoadingDetail.value = true;
    }

    try {
      currentProfile.value = await profileRepository.getCurrentProfile();
      await _checkTeamMembership(project);
      await refreshDetail();
    } catch (e) {
      loggy.error('Error abriendo prototipo: $e');
      detailError.value = 'No se pudo cargar la información del prototipo.';
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> _checkTeamMembership(Project project) async {
    final me = currentProfile.value?.id;
    if (me == null || me.isEmpty) {
      isTeamMember.value = false;
      return;
    }

    if (me == project.leaderId) {
      isTeamMember.value = true;
      return;
    }

    final projectId = project.id ?? '';
    if (projectId.isEmpty) {
      isTeamMember.value = false;
      return;
    }

    final apps = await applicationRepository.getApplicationsFor(projectId);
    final isAccepted = apps.any(
      (a) => a.applicantId == me && a.status == ApplicationStatus.accepted,
    );
    isTeamMember.value = isAccepted;
  }

  Future<void> refreshDetail() async {
    final pid = currentProject.value?.id;
    if (pid == null || pid.isEmpty) return;

    try {
      final cList = await showcaseRepository.getComments(pid);
      final fList = await showcaseRepository.getFeedback(pid);
      comments.value = cList;
      feedbackList.value = fList;

      commentCounts[pid] = cList.length;
      final summary = FeedbackSummary.fromList(fList);
      feedbackAverages[pid] = summary.overallAverage;
      feedbackCounts[pid] = summary.totalCount;
    } catch (e) {
      loggy.warning('Error refrescando detalle: $e');
    }
  }

  Future<bool> addComment(String text, {String? parentId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final pid = currentProject.value?.id;
    if (pid == null || pid.isEmpty) return false;

    // Solo el equipo puede responder
    if (parentId != null && parentId.isNotEmpty && !isTeamMember.value) {
      loggy.warning('Intento de respuesta por un usuario no perteneciente al equipo');
      return false;
    }

    // Solo un nivel de respuestas: si el comentario al que responde ya tiene parentId, no permitir
    if (parentId != null && parentId.isNotEmpty) {
      final parentComment = comments.firstWhereOrNull((c) => c.id == parentId);
      if (parentComment != null && parentComment.isReply) {
        loggy.warning('No se permiten respuestas anidadas de más de un nivel');
        return false;
      }
    }

    final profile = currentProfile.value;
    final comment = ProjectComment(
      projectId: pid,
      authorId: profile?.id ?? '',
      authorName: profile?.fullName.isNotEmpty == true
          ? profile!.fullName
          : 'Estudiante',
      text: trimmed,
      parentId: parentId,
      isTeam: isTeamMember.value,
      createdAt: DateTime.now(),
    );

    try {
      await showcaseRepository.addComment(comment);
      await refreshDetail();
      return true;
    } catch (e) {
      loggy.error('Error al agregar comentario: $e');
      return false;
    }
  }

  Future<bool> submitFeedback({
    required int usability,
    required int innovation,
    required int visualDesign,
    required int feasibility,
    String? comment,
  }) async {
    // El equipo no califica su propio proyecto
    if (isTeamMember.value) {
      loggy.warning('El equipo no puede calificar su propio proyecto');
      return false;
    }

    final pid = currentProject.value?.id;
    if (pid == null || pid.isEmpty) return false;

    final profile = currentProfile.value;
    final existing = myFeedback;

    final fb = ProjectFeedback(
      id: existing?.id,
      projectId: pid,
      authorId: profile?.id ?? '',
      authorName: profile?.fullName.isNotEmpty == true
          ? profile!.fullName
          : 'Estudiante',
      usability: usability,
      innovation: innovation,
      visualDesign: visualDesign,
      feasibility: feasibility,
      comment: comment?.trim().isNotEmpty == true ? comment!.trim() : null,
      createdAt: DateTime.now(),
    );

    try {
      await showcaseRepository.saveFeedback(fb);
      await refreshDetail();
      return true;
    } catch (e) {
      loggy.error('Error al guardar feedback: $e');
      return false;
    }
  }
}

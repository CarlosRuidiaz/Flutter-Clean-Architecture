import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../application/domain/models/application.dart';
import '../../../application/domain/repositories/i_application_repository.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../../project/domain/repositories/i_project_repository.dart';
import '../../domain/models/poll.dart';
import '../../domain/models/poll_response.dart';
import '../../domain/repositories/i_poll_repository.dart';

class PollController extends GetxController with UiLoggy {
  PollController(
    this.pollRepo,
    this.authRepo,
    this.profileRepo,
    this.projectRepo,
    this.appRepo,
  );

  final IPollRepository pollRepo;
  final IAuthRepository authRepo;
  final IProfileRepository profileRepo;
  final IProjectRepository projectRepo;
  final IApplicationRepository appRepo;

  final RxBool isLoading = false.obs;

  // Mapa de projectId -> lista de encuestas
  final RxMap<String, List<Poll>> projectPolls = <String, List<Poll>>{}.obs;
  
  // Mapa de pollId -> lista de respuestas
  final RxMap<String, List<PollResponse>> pollResponses = <String, List<PollResponse>>{}.obs;

  Future<void> loadPollsForProject(String projectId) async {
    loggy.debug('PollController: loadPollsForProject($projectId)');
    isLoading.value = true;
    try {
      final polls = await pollRepo.getPollsForProject(projectId);
      projectPolls[projectId] = polls;
      
      for (final poll in polls) {
        await loadResponsesForPoll(poll.id!);
      }
    } catch (e) {
      loggy.error('Error cargando encuestas para $projectId: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadResponsesForPoll(String pollId) async {
    try {
      final responses = await pollRepo.getResponsesForPoll(pollId);
      pollResponses[pollId] = responses;
    } catch (e) {
      loggy.error('Error cargando respuestas para $pollId: $e');
    }
  }

  Future<Poll?> createPoll(Poll poll) async {
    isLoading.value = true;
    try {
      final created = await pollRepo.createPoll(poll);
      final currentList = projectPolls[poll.projectId] ?? [];
      projectPolls[poll.projectId] = [...currentList, created];
      return created;
    } catch (e) {
      loggy.error('Error creando encuesta: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<PollResponse?> respondPoll(PollResponse response) async {
    isLoading.value = true;
    try {
      final created = await pollRepo.createResponse(response);
      final currentList = pollResponses[response.pollId] ?? [];
      pollResponses[response.pollId] = [...currentList, created];
      return created;
    } catch (e) {
      loggy.error('Error respondiendo encuesta: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> hasResponded(String pollId) async {
    final user = await authRepo.getLoggedUser();
    if (user == null) return false;
    
    final responses = pollResponses[pollId] ?? [];
    return responses.any((r) => r.respondentId == user.id);
  }

  Future<bool> canViewResults(Poll poll) async {
    if (!poll.isActive) return true;
    
    final user = await authRepo.getLoggedUser();
    if (user == null) return false;
    
    // Si ya respondio, puede ver
    if (await hasResponded(poll.id!)) return true;
    
    // Si es del equipo (lider o aceptado) puede ver
    final project = await projectRepo.getProjects().then((list) => list.firstWhereOrNull((p) => p.id == poll.projectId));
    if (project != null && project.leaderId == user.id) return true;
    
    final apps = await appRepo.getApplicationsFor(poll.projectId);
    final esMiembro = apps.any((a) => a.applicantId == user.id && a.status == ApplicationStatus.accepted);
    
    return esMiembro;
  }
  
  Future<bool> canRespond(Poll poll) async {
    if (!poll.isActive) return false;
    
    final user = await authRepo.getLoggedUser();
    if (user == null) return false;
    
    if (await hasResponded(poll.id!)) return false;
    
    if (poll.audienceProgram != null) {
      final profile = await profileRepo.getCurrentProfile();
      if (profile.academicProgram != poll.audienceProgram) {
        return false;
      }
    }
    
    return true;
  }
}

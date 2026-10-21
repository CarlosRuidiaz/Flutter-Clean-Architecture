import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/follow/data/datasources/local/local_follow_source.dart';
import 'package:f_clean_template/features/follow/data/repositories/follow_repository.dart';
import 'package:f_clean_template/features/follow/domain/repositories/i_follow_repository.dart';
import 'package:f_clean_template/features/follow/ui/viewmodels/follow_controller.dart';
import 'package:f_clean_template/features/poll/data/datasources/local/local_poll_source.dart';
import 'package:f_clean_template/features/poll/data/repositories/poll_repository.dart';
import 'package:f_clean_template/features/poll/domain/repositories/i_poll_repository.dart';
import 'package:f_clean_template/features/poll/ui/viewmodels/poll_controller.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:get/get.dart';

/// Registra seguir y encuestas con sus fuentes locales.
///
/// El detalle, el resumen del espacio de trabajo y "Mis proyectos" los buscan
/// con Get.find, asi que cualquier prueba que pinte esas pantallas los
/// necesita aunque no los mire.
void registrarSeguirYEncuestas({
  required IAuthRepository auth,
  required IProfileRepository perfiles,
  required IProjectRepository proyectos,
  required IApplicationRepository postulaciones,
}) {
  Get.put<IFollowRepository>(FollowRepository(LocalFollowSource()));
  Get.put(FollowController(Get.find<IFollowRepository>(), auth));
  Get.put<IPollRepository>(PollRepository(LocalPollSource()));
  Get.put(
    PollController(
      Get.find<IPollRepository>(),
      auth,
      perfiles,
      proyectos,
      postulaciones,
    ),
  );
}

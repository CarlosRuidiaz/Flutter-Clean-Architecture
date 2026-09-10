import 'package:get/get.dart';

import 'data/datasources/i_project_source.dart';
import 'data/datasources/local/local_project_source.dart';
import 'data/repositories/project_repository.dart';
import 'domain/repositories/i_project_repository.dart';
import 'ui/viewmodels/project_controller.dart';

void registerProject() {
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.lazyPut(() => ProjectController(Get.find()));
}
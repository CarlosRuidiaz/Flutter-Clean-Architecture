import 'package:get/get.dart';

import '../../../../my_projects/ui/viewmodels/my_projects_controller.dart';
import '../../../../project/ui/viewmodels/project_controller.dart';

/// Despues de cambiar el equipo o la etapa, la cartelera y "Mis proyectos" ya
/// no estan al dia: cada una guarda su propia copia de los proyectos.
///
/// Se pide solo si el controlador esta registrado, igual que hace el home al
/// volver de publicar una idea.
void refrescarListasDeProyectos() {
  if (Get.isRegistered<ProjectController>()) {
    Get.find<ProjectController>().getProjects();
  }
  if (Get.isRegistered<MyProjectsController>()) {
    Get.find<MyProjectsController>().reload();
  }
}

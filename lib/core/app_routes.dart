import 'package:get/get.dart';

import '../features/application/ui/views/application_status_page.dart';
import '../features/management/ui/views/applicants_page.dart';
import '../features/project/ui/views/create_idea_page.dart';
import '../features/project/ui/views/idea_published_page.dart';
import '../features/project/ui/views/project_detail_page.dart';
import '../features/project/ui/views/project_filters_page.dart';

/// Las rutas del flujo "crear una idea -> postularse -> aceptar la postulacion".
///
/// El homepage sigue siendo `home:` en `main.dart`, no una ruta con nombre.
/// Las pantallas 14 y 19 de Figma comparten ruta y clase: son la misma
/// pantalla dirigida por `Application.status`. La 15 es un
/// `showModalBottomSheet`, no una ruta.
abstract class AppRoutes {
  /// Pantalla 07. Recibe un `Project` por `Get.arguments`.
  static const String projectDetail = '/project-detail';

  /// Pantalla 10.
  static const String createIdea = '/create-idea';

  /// Pantalla 11.
  static const String ideaPublished = '/idea-published';

  /// Pantallas 14 y 19. Recibe una `Application` por `Get.arguments`.
  static const String applicationStatus = '/application-status';

  /// Pantalla 18. Recibe un `Project` por `Get.arguments`.
  static const String applicants = '/applicants';

  /// Los filtros de la cartelera. No recibe argumentos: lee y escribe el
  /// estado de `ProjectController`.
  static const String projectFilters = '/project-filters';

  static final List<GetPage> pages = [
    GetPage(name: projectDetail, page: () => const ProjectDetailPage()),
    GetPage(name: createIdea, page: () => const CreateIdeaPage()),
    GetPage(name: ideaPublished, page: () => const IdeaPublishedPage()),
    GetPage(
      name: applicationStatus,
      page: () => const ApplicationStatusPage(),
    ),
    GetPage(name: applicants, page: () => const ApplicantsPage()),
    GetPage(name: projectFilters, page: () => const ProjectFiltersPage()),
  ];
}

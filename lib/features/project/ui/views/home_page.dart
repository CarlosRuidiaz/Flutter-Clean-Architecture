import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../profile/ui/views/widgets/profile_skills_line.dart';

import '../../domain/models/project.dart';
import '../viewmodels/project_controller.dart';
import 'widgets/project_card.dart';
import 'widgets/explore_search_row.dart';

/// La cartelera. Dos pestanias sobre los mismos proyectos con dos criterios
/// distintos: la primera cruza con las habilidades del perfil, la segunda no.
///
/// Ninguna de las dos filtra aqui: piden al controlador la lista ya derivada.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _tappableCard(Project project) {
    return ProjectCard(
      project: project,
      onTap: () => Get.toNamed(AppRoutes.projectDetail, arguments: project),
    );
  }

  /// Estado vacio del sistema: una lista vacia sin explicacion se lee como un
  /// error de la app.
  Widget _emptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.gapXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.secondary),
            const SizedBox(height: AppTokens.gapM),
            Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppTokens.gapS),
            Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppTokens.gapL),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }

  Widget _projectList(List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppTokens.gapM),
      itemCount: projects.length,
      itemBuilder: (context, i) => _tappableCard(projects[i]),
    );
  }

  /// Pestania "Para tus habilidades".
  Widget _skillsTab(BuildContext context, ProjectController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final List<Project> projects = controller.projectsForMySkills;
      if (projects.isEmpty) {
        // Sin habilidades registradas el problema es el perfil; con ellas, que
        // ningun proyecto pide las suyas. Son dos vacios distintos.
        final bool sinHabilidades = controller.mySkills.isEmpty;
        return _emptyState(
          context: context,
          icon: sinHabilidades
              ? Icons.person_search_outlined
              : Icons.search_off_rounded,
          title: sinHabilidades
              ? 'Todavía no tienes habilidades registradas'
              : 'Ningún proyecto pide tus habilidades',
          message: sinHabilidades
              ? 'Sin habilidades en tu perfil no podemos saber qué proyectos '
                  'te sirven. Mientras tanto, puedes mirarlos todos.'
              : 'Ninguno de los proyectos publicados busca alguna de tus '
                  'habilidades. Prueba a mirar la cartelera completa.',
          actionLabel: 'Explorar proyectos',
          onAction: () => DefaultTabController.of(context).animateTo(1),
        );
      }

      return _projectList(projects);
    });
  }

  /// Pestania "Explorar proyectos": todo lo que pasa los filtros, sin cruzar
  /// con el perfil.
  Widget _exploreTab(BuildContext context, ProjectController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final List<Project> projects = controller.allVisibleProjects;
      if (projects.isEmpty) {
        return _emptyState(
          context: context,
          icon: Icons.filter_alt_off_outlined,
          title: 'Ningún proyecto coincide',
          message: 'Prueba quitando algún filtro o buscando con otras palabras.',
          actionLabel: 'Limpiar filtros',
          onAction: controller.clearFilters,
        );
      }

      return _projectList(projects);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProjectController controller = Get.find();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Innovation Hub'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Para tus habilidades'),
              Tab(text: 'Explorar proyectos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Builder a proposito: el boton del estado vacio salta a la otra
            // pestania con DefaultTabController.of, que necesita un contexto
            // por debajo del DefaultTabController. El de build esta por
            // encima y la busqueda fallaria.
            Builder(
              builder: (tabContext) => Column(
                children: [
                  // Sin buscador ni filtros a proposito: esta pestania ya esta
                  // filtrada por el perfil.
                  const ProfileSkillsLine(),
                  Expanded(child: _skillsTab(tabContext, controller)),
                ],
              ),
            ),
            Column(
              children: [
                // La fila sigue visible aunque la lista quede vacia: si
                // desapareciera, no habria forma de deshacer la busqueda.
                const ExploreSearchRow(),
                Expanded(child: _exploreTab(context, controller)),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          // TODO(carril diseno): quitar cuando la barra haga lo de Figma. Por
          // ahora el item "Crear" es la unica entrada a /create-idea.
          onTap: (index) {
            if (index == 2) Get.toNamed(AppRoutes.createIdea);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              label: 'Mis proyectos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Crear',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notificaciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

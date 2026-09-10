import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../profile/ui/views/widgets/profile_skills_line.dart';

import '../../domain/models/project.dart';
import '../viewmodels/project_controller.dart';
import 'widgets/project_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _tappableCard(Project project) {
    return ProjectCard(
      project: project,
      onTap: () => Get.toNamed(AppRoutes.projectDetail, arguments: project),
    );
  }

  Widget _projectList(ProjectController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: AppTokens.gapM),
        itemCount: controller.projects.length,
        itemBuilder: (context, i) => _tappableCard(controller.projects[i]),
      );
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

            Column(
              children: [
                const ProfileSkillsLine(),
                Expanded(child: _projectList(controller)),
              ],
            ),
            Column(
              children: [
                const SizedBox(height: AppTokens.gapS),
                Expanded(child: _projectList(controller)),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodels/project_controller.dart';
import 'widgets/project_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectController controller = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Innovation Hub')),
      body: Column(
        children: [
          // AQUI VA el widget de la pareja PROFILE:
          //     const ProfileSkillsLine(),
          // Se pone cuando esa pareja lo haya mergeado. Mientras tanto:
          const SizedBox(height: 8),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: controller.projects.length,
                itemBuilder: (context, i) =>
                    ProjectCard(project: controller.projects[i]),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
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
    );
  }
}
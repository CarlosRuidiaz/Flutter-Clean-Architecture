import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../../../follow/ui/viewmodels/follow_controller.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/ui/viewmodels/project_controller.dart';
import '../viewmodels/my_projects_controller.dart';
import 'widgets/compact_project_card.dart';

/// Vista "Mis proyectos" con tres pestañas: "Creados por mí", "Donde participo" y "Siguiendo".
class MyProjectsView extends StatelessWidget {
  const MyProjectsView({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyProjectsController>();
    final followController = Get.find<FollowController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis proyectos')),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Creados por mí'),
                Tab(text: 'Donde participo'),
                Tab(text: 'Siguiendo'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CreatedTab(controller: controller, theme: theme),
                  _ParticipatingTab(
                    controller: controller,
                    theme: theme,
                    onExplore: onExplore,
                  ),
                  _FollowingTab(
                    controller: followController,
                    theme: theme,
                    onExplore: onExplore,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Pestaña "Creados por mí"
// ───────────────────────────────────────────────────────────────────────────

class _CreatedTab extends StatelessWidget {
  const _CreatedTab({required this.controller, required this.theme});

  final MyProjectsController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.error.value.isNotEmpty) {
        return _ErrorState(
          message: 'No pudimos cargar tus proyectos',
          onRetry: controller.reload,
          theme: theme,
        );
      }

      if (controller.isLoading.value && controller.createdProjects.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.reload,
        child: controller.createdProjects.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTokens.gapXl),
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppTokens.gapXl),
                      Text(
                        'Todavía no has creado proyectos',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTokens.gapM),
                      ElevatedButton(
                        onPressed: () async {
                          await Get.toNamed(AppRoutes.createIdea);
                          controller.reload();
                        },
                        child: const Text('Publicar una idea'),
                      ),
                    ],
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTokens.gapL),
                itemCount: controller.createdProjects.length,
                itemBuilder: (context, index) {
                  final project = controller.createdProjects[index];
                  final pending = controller.pendingFor(project.id);
                  final label = pending == 1 ? '1 pendiente' : '$pending pendientes';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.gapM),
                    child: CompactProjectCard(
                      project: project,
                      onTap: () async {
                        await Get.toNamed(AppRoutes.projectDetail, arguments: project);
                        controller.reload();
                      },
                      trailing: Pill(
                        label: label,
                        background: AppColors.card,
                        foreground: pending > 0 ? AppColors.persimmon : AppColors.secondary,
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Pestaña "Donde participo"
// ───────────────────────────────────────────────────────────────────────────

class _ParticipatingTab extends StatelessWidget {
  const _ParticipatingTab({
    required this.controller,
    required this.theme,
    this.onExplore,
  });

  final MyProjectsController controller;
  final ThemeData theme;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.error.value.isNotEmpty) {
        return _ErrorState(
          message: 'No pudimos cargar tus proyectos',
          onRetry: controller.reload,
          theme: theme,
        );
      }

      if (controller.isLoading.value && controller.participatingProjects.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.reload,
        child: controller.participatingProjects.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTokens.gapXl),
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppTokens.gapXl),
                      Text(
                        'Todavía no participas en ningún proyecto',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTokens.gapM),
                      ElevatedButton(
                        onPressed: onExplore,
                        child: const Text('Explorar proyectos'),
                      ),
                    ],
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTokens.gapL),
                itemCount: controller.participatingProjects.length,
                itemBuilder: (context, index) {
                  final project = controller.participatingProjects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.gapM),
                    child: CompactProjectCard(
                      project: project,
                      onTap: () async {
                        await Get.toNamed(AppRoutes.projectDetail, arguments: project);
                        controller.reload();
                      },
                    ),
                  );
                },
              ),
      );
    });
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Pestaña "Siguiendo"
// ───────────────────────────────────────────────────────────────────────────

class _FollowingTab extends StatelessWidget {
  const _FollowingTab({
    required this.controller,
    required this.theme,
    this.onExplore,
  });

  final FollowController controller;
  final ThemeData theme;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final projectController = Get.find<ProjectController>();

    return Obx(() {
      if (controller.isLoading.value && controller.follows.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.reload();
          await projectController.getProjects();
        },
        child: controller.follows.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTokens.gapXl),
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppTokens.gapXl),
                      Text(
                        'No sigues ningún proyecto',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTokens.gapM),
                      ElevatedButton(
                        onPressed: onExplore,
                        child: const Text('Explorar proyectos'),
                      ),
                    ],
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTokens.gapL),
                itemCount: controller.follows.length,
                itemBuilder: (context, index) {
                  final follow = controller.follows[index];
                  final project = projectController.projects.firstWhereOrNull((p) => p.id == follow.projectId);
                  
                  if (project == null) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.gapM),
                    child: CompactProjectCard(
                      project: project,
                      onTap: () async {
                        await Get.toNamed(AppRoutes.projectDetail, arguments: project);
                        controller.reload();
                      },
                    ),
                  );
                },
              ),
      );
    });
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Estado de error compartido
// ───────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.theme,
  });

  final String message;
  final VoidCallback onRetry;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.gapXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapM),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

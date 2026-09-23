import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../viewmodels/my_projects_controller.dart';
import 'widgets/compact_project_card.dart';

/// Vista "Mis proyectos" con dos pestañas: "Creados por mí" y "Donde participo".
class MyProjectsView extends StatelessWidget {
  const MyProjectsView({super.key, this.onExplore});

  /// Se llama cuando el usuario pulsa "Explorar proyectos" en el estado vacío
  /// de la pestaña "Donde participo". El padre (HomePage) lo usa para saltar a
  /// la cartelera.
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyProjectsController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis proyectos')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Creados por mí'),
                Tab(text: 'Donde participo'),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.error.value.isNotEmpty) {
                  return _ErrorState(
                    message: 'No pudimos cargar tus proyectos',
                    onRetry: controller.reload,
                    theme: theme,
                  );
                }

                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  children: [
                    _CreatedTab(controller: controller, theme: theme),
                    _ParticipatingTab(
                      controller: controller,
                      theme: theme,
                      onExplore: onExplore,
                    ),
                  ],
                );
              }),
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
    if (controller.createdProjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.gapXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.reload,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTokens.gapL),
        itemCount: controller.createdProjects.length,
        itemBuilder: (context, index) {
          final project = controller.createdProjects[index];
          final pending = controller.pendingFor(project.id);
          final label =
              pending == 1 ? '1 pendiente' : '$pending pendientes';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.gapM),
            child: CompactProjectCard(
              project: project,
              onTap: () async {
                await Get.toNamed(AppRoutes.projectDetail,
                    arguments: project);
                controller.reload();
              },
              trailing: Pill(
                label: label,
                background: AppColors.card,
                foreground: pending > 0
                    ? AppColors.persimmon
                    : AppColors.secondary,
              ),
            ),
          );
        },
      ),
    );
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
    if (controller.participatingProjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.gapXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.reload,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTokens.gapL),
        itemCount: controller.participatingProjects.length,
        itemBuilder: (context, index) {
          final project = controller.participatingProjects[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.gapM),
            child: CompactProjectCard(
              project: project,
              onTap: () async {
                await Get.toNamed(AppRoutes.projectDetail,
                    arguments: project);
                controller.reload();
              },
            ),
          );
        },
      ),
    );
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

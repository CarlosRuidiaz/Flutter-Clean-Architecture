import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_tokens.dart';
import '../viewmodels/showcase_controller.dart';
import 'widgets/showcase_project_card.dart';

class ShowcaseView extends StatelessWidget {
  const ShowcaseView({super.key});

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: AppTokens.borderRadius,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppTokens.borderRadius,
          border: AppTokens.border(),
          boxShadow: AppTokens.hardShadow(),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.chevron_left_rounded,
          color: AppColors.ink,
          size: 26,
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, ShowcaseController controller) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.gapL,
          vertical: AppTokens.gapXl * 2,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.science_outlined,
              size: 54,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppTokens.gapM),
            Text(
              'No hay prototipos en vitrina',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapS),
            Text(
              'Por ahora ningún proyecto se encuentra en la etapa Prototype.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapL),
            OutlinedButton(
              onPressed: controller.loadPrototypeProjects,
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(BuildContext context, ShowcaseController controller) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.gapL,
          vertical: AppTokens.gapXl * 2,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AppColors.persimmon,
            ),
            const SizedBox(height: AppTokens.gapM),
            Text(
              'Ocurrió un error al cargar',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapS),
            Text(
              controller.showcaseError.value.isNotEmpty
                  ? controller.showcaseError.value
                  : 'No se pudo conectar con el servidor.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapL),
            ElevatedButton(
              onPressed: controller.loadPrototypeProjects,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ShowcaseController controller = Get.find<ShowcaseController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera superior
            Padding(
              padding: const EdgeInsets.only(
                left: AppTokens.gapL,
                top: AppTokens.gapL,
                right: AppTokens.gapL,
                bottom: AppTokens.gapM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(context),
                  const SizedBox(height: AppTokens.gapM),
                  Text(
                    'Vitrina de prototipos',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppTokens.gapL),
              child: Text(
                'Proyectos en etapa Prototype, abiertos a comentarios de toda la universidad.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final isLoading = controller.isLoadingShowcase.value;
                final error = controller.showcaseError.value;
                final projects = controller.prototypeProjects;

                if (isLoading && projects.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (error.isNotEmpty && projects.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.loadPrototypeProjects,
                    child: _errorState(context, controller),
                  );
                }

                if (projects.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.loadPrototypeProjects,
                    child: _emptyState(context, controller),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadPrototypeProjects,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: AppTokens.gapS,
                      bottom: AppTokens.gapXl,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final pid = project.id ?? '';
                      final commentCount = controller.commentCounts[pid] ?? 0;
                      final overallAverage =
                          controller.feedbackAverages[pid] ?? 0.0;

                      return ShowcaseProjectCard(
                        project: project,
                        commentCount: commentCount,
                        overallAverage: overallAverage,
                        onTap: () {
                          controller.openProject(project);
                          Get.toNamed(
                            AppRoutes.prototypeDetail,
                            arguments: project,
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

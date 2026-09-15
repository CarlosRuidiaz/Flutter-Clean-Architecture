import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/paper_card.dart';
import '../../../../core/widgets/pill.dart';
import '../../domain/models/project.dart';

class IdeaPublishedPage extends StatelessWidget {
  const IdeaPublishedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Project? project =
        Get.arguments is Project ? Get.arguments as Project : null;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No se recibió el proyecto')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Idea publicada'),
        backgroundColor: AppColors.paper,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.gapXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.petrol,
              ),
              const SizedBox(height: AppTokens.gapL),
              Text(
                'Tu idea ya está en la cartelera',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
              ),
              const SizedBox(height: AppTokens.gapXl),
              PaperCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.gapL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppTokens.gapM),
                      if (project.skillsWanted.isNotEmpty) ...[
                        Wrap(
                          spacing: AppTokens.gapXs,
                          runSpacing: AppTokens.gapXs,
                          children: project.skillsWanted
                              .map((s) => Pill(label: s))
                              .toList(),
                        ),
                        const SizedBox(height: AppTokens.gapM),
                      ],
                      Text(
                        'Máximo ${project.maxMembers} miembros · ${project.academicProgram}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.gapXl * 2),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.projectDetail, arguments: project);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.persimmon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTokens.borderRadius,
                  ),
                  elevation: 0,
                ),
                child: const Text('Ver mi idea publicada'),
              ),
              const SizedBox(height: AppTokens.gapM),
              OutlinedButton(
                onPressed: () {
                  Get.until((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: AppTokens.border(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTokens.borderRadius,
                  ),
                ),
                child: const Text('Ver proyectos publicados'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

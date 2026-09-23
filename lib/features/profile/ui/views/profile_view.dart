import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../../../auth/ui/viewmodels/authentication_controller.dart';
import '../../../my_projects/ui/viewmodels/my_projects_controller.dart';
import '../../../my_projects/ui/views/widgets/compact_project_card.dart';
import '../viewmodels/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _confirmarCierreDeSesion(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radius * 3),
        ),
        side: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
      ),
      builder: (sheetContext) {
        final TextTheme textTheme = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.gapL,
              vertical: AppTokens.gapXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¿Cerrar sesión?',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.gapM),
                Text(
                  'Volverás a la pantalla de inicio de sesión. Tus ideas y '
                  'postulaciones se quedan como están.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.gapXl),
                ElevatedButton(
                  onPressed: () async {
                    await Get.find<AuthenticationController>().logOut();
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: const Text('Sí, cerrar sesión'),
                ),
                const SizedBox(height: AppTokens.gapS),
                OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    final projectsCtrl = Get.find<MyProjectsController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Obx(() {
        if (profileCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profileCtrl.profile == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.gapXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No pudimos cargar tu perfil',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.gapM),
                  ElevatedButton(
                    onPressed: profileCtrl.getCurrentProfile,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = profileCtrl.profile!;
        final activeProjectsCount = projectsCtrl.activeProjectsCount;

        final parts = profile.fullName.trim().split(RegExp(r'\s+'));
        final initials = parts.length >= 2
            ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
            : (parts.isNotEmpty && parts.first.isNotEmpty
                ? parts.first.substring(0, 1).toUpperCase()
                : '?');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.gapXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.gold,
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.gapL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.academicProgram} · ${profile.semester}.º semestre',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeProjectsCount == 1
                              ? '1 proyecto activo'
                              : '$activeProjectsCount proyectos activos',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.persimmon,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.gapXl),
              Text(
                'Habilidades e intereses',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTokens.gapM),
              if (profile.skills.isNotEmpty)
                Wrap(
                  spacing: AppTokens.gapXs,
                  runSpacing: AppTokens.gapXs,
                  children:
                      profile.skills.map((s) => Pill(label: s)).toList(),
                )
              else
                Text('No has registrado habilidades.',
                    style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppTokens.gapXl),
              Text(
                'Proyectos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTokens.gapM),
              if (activeProjectsCount == 0)
                Text('No tienes proyectos activos.',
                    style: theme.textTheme.bodyMedium)
              else ...[
                ...projectsCtrl.createdProjects.map((p) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTokens.gapM),
                      child: CompactProjectCard(
                        project: p,
                        // La tarjeta ya dice "N de M miembros": aqui solo el papel.
                        bottomWidget: Text(
                          'Líder',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )),
                ...projectsCtrl.participatingProjects.map((p) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTokens.gapM),
                      child: CompactProjectCard(
                        project: p,
                        bottomWidget: Text(
                          'Participa',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )),
              ],
              const SizedBox(height: AppTokens.gapXl * 2),
              OutlinedButton(
                onPressed: () => _confirmarCierreDeSesion(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(
                      color: AppColors.ink, width: AppTokens.borderWidth),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../../../application/domain/models/application.dart';
import '../../../application/ui/viewmodels/application_controller.dart';
import '../../../profile/ui/viewmodels/profile_controller.dart';
import '../../domain/models/project.dart';
import 'widgets/stage_chip.dart';

/// Pantalla 07 de Figma: Detalle de un proyecto con el flujo de postulación.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key});

  Widget _buildTeamAvatars() {
    //Project no tiene lista de miembros todavía
    const initials = ['SR', 'MC', 'AP', 'CS'];
    return Row(
      children: [
        for (final item in initials) ...[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: AppTokens.border(),
            ),
            alignment: Alignment.center,
            child: Text(
              item,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.gapS),
        ],
      ],
    );
  }

  /// El estudiante en sesión. El perfil de prueba es el '1'.
  String _applicantId() {
    final profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().profile
        : null;
    return profile?.id ?? '1';
  }

  Widget _buildFooterButtons(BuildContext context, Project project) {
    final controller = Get.find<ApplicationController>();

    return Obx(() {
      // Si ya hay una postulación viva a este proyecto, la pantalla 07 lleva a
      // verla en vez de ofrecer postularse otra vez. Es la única entrada a la
      // pantalla 19 mientras la 18 no exista, y evita duplicados.
      final vigente = controller.vigenteEn(project.id ?? '');

      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {}, // Decorativo según especificación Figma
              child: const Text('Seguir'),
            ),
          ),
          if (vigente != null) ...[
            const SizedBox(width: AppTokens.gapM),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.applicationStatus,
                  arguments: vigente,
                ),
                child: const Text('Ver mi postulación'),
              ),
            ),
          ] else if (project.acceptsApplications) ...[
            const SizedBox(width: AppTokens.gapM),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final profile = Get.isRegistered<ProfileController>()
                      ? Get.find<ProfileController>().profile
                      : null;
                  final application = Application(
                    projectId: project.id ?? '',
                    applicantId: _applicantId(),
                    applicantName: profile?.fullName ?? 'Carlos Ruidíaz',
                    applicantProgram:
                        profile?.academicProgram ?? 'Ingeniería de Sistemas',
                    applicantSemester: profile?.semester ?? 8,
                    skillsOffered: profile?.skills ?? const [],
                    status: ApplicationStatus.pending,
                  );
                  final created = await controller.apply(application);
                  Get.toNamed(AppRoutes.applicationStatus, arguments: created);
                },
                child: const Text('Postularme'),
              ),
            ),
          ],
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Project? project = Get.arguments is Project
        ? Get.arguments as Project
        : null;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(
          child: Text('Get.arguments llegó vacío: se esperaba un Project.'),
        ),
      );
    }

    final TextTheme textTheme = Theme.of(context).textTheme;

    // Al abrir el detalle hay que saber si ya existe una postulación a este
    // proyecto. Va despues del primer frame para no cambiar un Rx durante build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ApplicationController>().ensureMyApplications(_applicantId());
    });

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.gapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Etapa + tags del proyecto
            Wrap(
              spacing: AppTokens.gapS,
              runSpacing: AppTokens.gapXs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StageChip(stage: project.stage),
                for (final tag in project.tags)
                  Pill(label: tag, background: AppColors.card),
              ],
            ),
            const SizedBox(height: AppTokens.gapM),

            // Título del proyecto y programa académico
            Text(project.title, style: textTheme.headlineMedium),
            const SizedBox(height: AppTokens.gapXs),
            Text(project.academicProgram, style: textTheme.bodySmall),
            const SizedBox(height: AppTokens.gapM),

            // Contador de miembros
            Text(
              '${project.currentMembers} de ${project.maxMembers} miembros',
              style: textTheme.bodyMedium?.copyWith(
                color: project.isFull ? AppColors.persimmon : AppColors.ink,
                fontWeight: project.isFull
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(height: AppTokens.gapL),

            // Problema a resolver (si existe)
            if (project.problem.isNotEmpty) ...[
              Text('Problema a resolver', style: textTheme.titleMedium),
              const SizedBox(height: AppTokens.gapS),
              Text(project.problem, style: textTheme.bodyLarge),
              const SizedBox(height: AppTokens.gapL),
            ],

            // Descripción
            Text('Descripción', style: textTheme.titleMedium),
            const SizedBox(height: AppTokens.gapS),
            Text(project.description, style: textTheme.bodyLarge),
            const SizedBox(height: AppTokens.gapL),

            // Habilidades requeridas
            Text('Habilidades requeridas', style: textTheme.titleMedium),
            const SizedBox(height: AppTokens.gapS),
            if (project.skillsWanted.isNotEmpty)
              Wrap(
                spacing: AppTokens.gapS,
                runSpacing: AppTokens.gapS,
                children: project.skillsWanted
                    .map((s) => Pill(label: s, background: AppColors.card))
                    .toList(),
              )
            else
              Text(
                'No se requieren habilidades específicas',
                style: textTheme.bodySmall,
              ),
            const SizedBox(height: AppTokens.gapL),

            // Equipo actual
            Text('Equipo actual', style: textTheme.titleMedium),
            const SizedBox(height: AppTokens.gapS),
            _buildTeamAvatars(),
            const SizedBox(height: AppTokens.gapXl),

            // Botones del pie
            _buildFooterButtons(context, project),

            // Solo el lider del proyecto gestiona sus postulantes.
            if (project.leaderId == _applicantId()) ...[
              const SizedBox(height: AppTokens.gapM),
              OutlinedButton(
                onPressed: () =>
                    Get.toNamed(AppRoutes.applicants, arguments: project),
                child: const Text('Gestionar postulantes'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

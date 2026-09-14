import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/paper_card.dart';
import '../../../../core/widgets/pill.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/ui/views/widgets/stage_chip.dart';
import '../../domain/models/application.dart';
import '../viewmodels/application_controller.dart';
import 'widgets/withdraw_sheet.dart';

/// Pantallas 14 y 19 de Figma: son la misma pantalla dirigida por [Application.status].
///
/// Cambian el icono, el título, el texto explicativo, la etiqueta de estado y
/// los botones del pie. El título y la etapa del proyecto se consultan a
/// [IProjectRepository] a través de [ApplicationController].
class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

  Widget _buildProjectCard(
    BuildContext context,
    ApplicationController controller,
    String projectId,
  ) {
    return FutureBuilder<Project?>(
      future: controller.getProject(projectId),
      builder: (context, snapshot) {
        final project = snapshot.data;
        final textTheme = Theme.of(context).textTheme;

        if (project == null) {
          return PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Proyecto', style: textTheme.bodySmall),
                const SizedBox(height: AppTokens.gapS),
                Text(
                  'Identificador: $projectId',
                  style: textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return PaperCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StageChip(stage: project.stage),
                  const SizedBox(width: AppTokens.gapS),
                  Expanded(
                    child: Text(
                      project.academicProgram,
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.gapM),
              Text(project.title, style: textTheme.titleMedium),
              const SizedBox(height: AppTokens.gapS),
              Text(
                '${project.currentMembers} de ${project.maxMembers} miembros',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Application? initialApp =
        Get.arguments is Application ? Get.arguments as Application : null;

    final ApplicationController controller = Get.find();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi postulación')),
      body: Obx(() {
        final Application? application = controller.myApplications
                .firstWhereOrNull((a) => a.id == initialApp?.id) ??
            initialApp;

        if (application == null) {
          return const Center(
            child: Text(
              'Get.arguments llegó vacío: se esperaba una Application.',
            ),
          );
        }

        final bool isPending = application.isPending;
        final bool isAccepted =
            application.status == ApplicationStatus.accepted;
        final bool isWithdrawn =
            application.status == ApplicationStatus.withdrawn;

        // Configuración según el estado (Pantalla 14 vs Pantalla 19)
        final IconData iconData;
        final Color iconColor;
        final String title;
        final String subtitle;
        final Widget statusPill;

        if (isAccepted) {
          iconData = Icons.check_circle_outline_rounded;
          iconColor = AppColors.petrol;
          title = 'Ya eres parte del equipo';
          subtitle =
              '¡Felicitaciones! Has sido aceptado en el proyecto. Puedes comunicarte con el equipo y comenzar a colaborar.';
          statusPill = const Pill(
            label: 'Aceptada',
            background: AppColors.petrol,
            foreground: Colors.white,
          );
        } else if (isWithdrawn) {
          iconData = Icons.cancel_outlined;
          iconColor = AppColors.secondary;
          title = 'Postulación cancelada';
          subtitle = 'Has cancelado tu postulación a este proyecto.';
          statusPill = const Pill(
            label: 'Cancelada',
            background: AppColors.card,
          );
        } else if (isPending) {
          iconData = Icons.schedule_rounded;
          iconColor = AppColors.persimmon;
          title = 'Tu postulación está en revisión';
          subtitle =
              'El líder del proyecto está evaluando tu perfil y tus habilidades. Te avisaremos cuando haya una respuesta.';
          statusPill = const Pill(
            label: 'Pendiente',
            background: AppColors.gold,
          );
        } else {
          iconData = Icons.highlight_off_rounded;
          iconColor = AppColors.secondary;
          title = 'Postulación no seleccionada';
          subtitle =
              'El líder del proyecto ha completado el equipo con otros perfiles.';
          statusPill = const Pill(
            label: 'Rechazada',
            background: AppColors.card,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.gapL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTokens.gapL),
              // Icono de estado
              Center(
                child: Icon(
                  iconData,
                  size: 64,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: AppTokens.gapM),

              // Etiqueta de estado
              Center(child: statusPill),
              const SizedBox(height: AppTokens.gapL),

              // Título
              Text(
                title,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.gapM),

              // Texto descriptivo
              Text(
                subtitle,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.gapXl),

              // Tarjeta del proyecto en medio
              _buildProjectCard(context, controller, application.projectId),
              const SizedBox(height: AppTokens.gapXl),

              // Botones del pie según pantalla 14 o 19
              if (isPending && application.canWithdraw) ...[
                OutlinedButton(
                  onPressed: () {
                    WithdrawSheet.show(
                      context,
                      applicationId: application.id ?? '',
                    );
                  },
                  child: const Text('Cancelar postulación'),
                ),
                const SizedBox(height: AppTokens.gapM),
                Text(
                  'Puedes volver a postularte mientras el reclutamiento siga abierto.',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ] else if (isAccepted) ...[
                ElevatedButton(
                  onPressed: () {
                    // TODO(semana siguiente): navegar al espacio del proyecto.
                  },
                  child: const Text('Ir al espacio del proyecto'),
                ),
                const SizedBox(height: AppTokens.gapS),
                OutlinedButton(
                  onPressed: () {
                    // TODO(semana siguiente): confirmar salida del proyecto.
                  },
                  child: const Text('Salir del proyecto'),
                ),
              ] else if (isWithdrawn) ...[
                Text(
                  'Puedes volver a postularte mientras el reclutamiento siga abierto.',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

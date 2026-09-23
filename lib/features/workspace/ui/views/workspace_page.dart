import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_tokens.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/ui/views/widgets/stage_chip.dart';
import '../viewmodels/workspace_controller.dart';
import 'widgets/progress_tab.dart';
import 'widgets/summary_tab.dart';
import 'widgets/tasks_tab.dart';

/// El espacio de trabajo del proyecto: el lugar privado del equipo, distinto
/// del detalle publico. Solo entran el lider y los miembros aceptados.
class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage>
    with SingleTickerProviderStateMixin {
  final WorkspaceController _controller = Get.find();
  late final TabController _tabController;
  Worker? _tabWorker;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _controller.tabIndex.value,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.tabIndex.value = _tabController.index;
      }
    });
    // Publicar un avance deja marcada la pestania de avances antes de volver:
    // este worker es lo que mueve el TabController hasta ahi.
    _tabWorker = ever<int>(_controller.tabIndex, (index) {
      if (_tabController.index != index) _tabController.animateTo(index);
    });
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Project? project =
        Get.arguments is Project ? Get.arguments as Project : null;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Espacio de trabajo')),
        body: const Center(
          child: Text('Get.arguments llegó vacío: se esperaba un Project.'),
        ),
      );
    }

    // El perfil se pide cada vez que se abre, no solo cuando se crea el
    // controlador: si guardara el de la primera vez, otra cuenta heredaria
    // los permisos de la anterior.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.open(project);
    });

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!_controller.canEnter) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTokens.gapL),
              child: Text(
                'No tienes acceso a este espacio de trabajo: es solo para el '
                'líder y los miembros aceptados.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final int total = _controller.totalMilestones;
        final int cumplidos = _controller.completedMilestones;
        final int porcentaje = _controller.progressPercent;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.gapL,
                AppTokens.gapL,
                AppTokens.gapL,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(width: AppTokens.gapS),
                      StageChip(stage: project.stage),
                    ],
                  ),
                  const SizedBox(height: AppTokens.gapM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        total == 0
                            ? 'Sin hitos todavía'
                            : 'Avance · $cumplidos de $total hitos',
                        style: textTheme.bodyMedium,
                      ),
                      Text('$porcentaje %', style: textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: AppTokens.gapS),
                  _ProgressBar(percent: porcentaje),
                  const SizedBox(height: AppTokens.gapS),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Resumen'),
                Tab(text: 'Avances'),
                Tab(text: 'Tareas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  WorkspaceSummaryTab(),
                  WorkspaceProgressTab(),
                  WorkspaceTasksTab(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// La barra de avance: relleno persimmon sobre fondo de papel, con marcas
/// cortas debajo a modo de regla graduada.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final double factor = percent.clamp(0, 100) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 10,
            child: Stack(
              children: [
                Container(color: AppColors.paper),
                FractionallySizedBox(
                  widthFactor: factor,
                  child: Container(color: AppColors.persimmon),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (int i = 0; i < 10; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              const Expanded(
                child: SizedBox(
                  height: 4,
                  child: ColoredBox(color: AppColors.secondary),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

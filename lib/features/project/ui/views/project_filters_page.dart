import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_catalogs.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../../domain/models/project.dart';
import '../viewmodels/project_controller.dart';
import 'widgets/stage_chip.dart';

/// La pantalla de filtros de la cartelera: tres grupos de seleccion multiple.
///
/// Trabaja sobre una copia local de la seleccion y solo la vuelca al
/// controlador al pulsar "Aplicar". Salir con el boton de volver deja los
/// filtros como estaban: eso es lo que hace que "Aplicar" signifique algo.
class ProjectFiltersPage extends StatefulWidget {
  const ProjectFiltersPage({super.key});

  @override
  State<ProjectFiltersPage> createState() => _ProjectFiltersPageState();
}

class _ProjectFiltersPageState extends State<ProjectFiltersPage> {
  final ProjectController _controller = Get.find();

  late final List<String> _skills;
  late final List<String> _programs;
  late final List<ProjectStage> _stages;

  @override
  void initState() {
    super.initState();
    // Copias, no las listas del controlador: si se editaran en sitio, el
    // boton de volver no podria deshacer nada.
    _skills = List<String>.from(_controller.skillFilters);
    _programs = List<String>.from(_controller.programFilters);
    _stages = List<ProjectStage>.from(_controller.stageFilters);
  }

  /// Cuantos grupos tienen algo marcado en la seleccion en curso, que puede no
  /// ser todavia la del controlador.
  int get _seleccionados =>
      (_skills.isEmpty ? 0 : 1) +
      (_programs.isEmpty ? 0 : 1) +
      (_stages.isEmpty ? 0 : 1);

  void _toggle<T>(List<T> seleccion, T valor) {
    setState(() {
      if (seleccion.contains(valor)) {
        seleccion.remove(valor);
      } else {
        seleccion.add(valor);
      }
    });
  }

  /// Pildora pulsable. Seleccionada se pinta con [selectedColor]; sin
  /// seleccionar va sobre la superficie de tarjeta, como manda el sistema.
  Widget _filterPill({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Pill(
        label: label,
        background: selected ? selectedColor : AppColors.card,
      ),
    );
  }

  /// La clave identifica al grupo. Hace falta porque dos grupos pueden pintar
  /// el mismo texto: la etapa `research` se dice "Investigación" y es tambien
  /// una habilidad del catalogo.
  Widget _group({
    required Key key,
    required String title,
    required List<Widget> chips,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppTokens.gapM),
        Wrap(
          spacing: AppTokens.gapS,
          runSpacing: AppTokens.gapS,
          children: chips,
        ),
        const SizedBox(height: AppTokens.gapXl),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filtros')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.gapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _group(
              key: const ValueKey('grupo-habilidades'),
              title: 'Habilidades',
              chips: [
                for (final skill in AppCatalogs.skills)
                  _filterPill(
                    label: skill,
                    selected: _skills.contains(skill),
                    selectedColor: AppColors.persimmon,
                    onTap: () => _toggle(_skills, skill),
                  ),
              ],
            ),
            _group(
              key: const ValueKey('grupo-programas'),
              title: 'Programa académico',
              chips: [
                for (final program in AppCatalogs.academicPrograms)
                  _filterPill(
                    label: program,
                    selected: _programs.contains(program),
                    selectedColor: AppColors.petrol,
                    onTap: () => _toggle(_programs, program),
                  ),
              ],
            ),
            _group(
              key: const ValueKey('grupo-etapas'),
              title: 'Etapa del proyecto',
              chips: [
                for (final stage in ProjectStage.values)
                  _filterPill(
                    label: StageChip.labelOf(stage),
                    selected: _stages.contains(stage),
                    selectedColor: StageChip.colorOf(stage),
                    onTap: () => _toggle(_stages, stage),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.gapL),
          child: ElevatedButton(
            // Sin nada marcado sigue activo: aplicar cero es valido, limpia
            // lo que hubiera antes.
            onPressed: () {
              _controller.applyFilters(
                skills: _skills,
                programs: _programs,
                stages: _stages,
              );
              Get.back();
            },
            child: Text(
              _seleccionados == 0
                  ? 'Aplicar filtros'
                  : 'Aplicar $_seleccionados ${_seleccionados == 1 ? "filtro" : "filtros"}',
            ),
          ),
        ),
      ),
    );
  }
}

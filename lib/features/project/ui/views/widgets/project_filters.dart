import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/pill.dart';
import '../../../domain/models/project.dart';
import '../../viewmodels/project_controller.dart';
import 'stage_chip.dart';

/// La fila de filtros de la cartelera: busqueda por titulo, etapa y "solo
/// abiertos a postulacion".
///
/// Vive aparte para que `home_page.dart` no crezca sin control. No filtra nada
/// por su cuenta: solo escribe en el estado del controlador, que es quien
/// deriva las listas.
class ProjectFilters extends StatefulWidget {
  const ProjectFilters({super.key});

  @override
  State<ProjectFilters> createState() => _ProjectFiltersState();
}

class _ProjectFiltersState extends State<ProjectFilters> {
  final ProjectController _controller = Get.find();
  late final TextEditingController _searchController;
  late final StreamSubscription<String> _searchSubscription;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: _controller.searchQuery.value,
    );
    // El campo es de esta vista pero la verdad esta en el controlador: si otra
    // pantalla limpia los filtros, el texto escrito tiene que irse con ellos.
    //
    // La suscripcion se guarda para cancelarla: las dos pestanias montan su
    // propia fila de filtros sobre el mismo Rx, y una que sobreviva a su
    // widget escribiria en un TextEditingController ya descartado.
    _searchSubscription = _controller.searchQuery.listen((valor) {
      if (_searchController.text != valor) _searchController.text = valor;
    });
  }

  @override
  void dispose() {
    _searchSubscription.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Pildora pulsable. Seleccionada se pinta con [selectedColor]; sin
  /// seleccionar va sobre la superficie de tarjeta, como manda el sistema.
  Widget _filterPill({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTokens.gapS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Pill(
          label: label,
          background: selected ? selectedColor : AppColors.card,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.gapL,
        AppTokens.gapS,
        AppTokens.gapL,
        AppTokens.gapS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _controller.setSearchQuery,
            decoration: const InputDecoration(
              hintText: 'Buscar por título',
              prefixIcon: Icon(Icons.search, color: AppColors.secondary),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppTokens.gapM),
          Obx(() {
            final ProjectStage? seleccionada = _controller.stageFilter.value;
            return SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // "Todas" no es una etapa y no tiene color propio en
                  // AppStageColors: seleccionada se pinta con la tinta.
                  _filterPill(
                    label: 'Todas',
                    selected: seleccionada == null,
                    selectedColor: AppColors.ink,
                    onTap: () => _controller.setStageFilter(null),
                  ),
                  for (final stage in ProjectStage.values)
                    _filterPill(
                      label: StageChip.labelOf(stage),
                      selected: seleccionada == stage,
                      selectedColor: StageChip.colorOf(stage),
                      onTap: () => _controller.setStageFilter(stage),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppTokens.gapS),
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(
              () => _filterPill(
                label: 'Solo abiertos a postulación',
                selected: _controller.onlyOpen.value,
                selectedColor: AppColors.petrol,
                onTap: _controller.toggleOnlyOpen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

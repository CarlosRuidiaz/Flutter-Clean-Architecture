import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_routes.dart';
import '../../../../../core/app_tokens.dart';
import '../../viewmodels/project_controller.dart';

/// La fila de "Explorar proyectos": el campo de busqueda y el boton que abre
/// la pantalla de filtros, con el contador de grupos marcados.
///
/// Vive aparte para que `home_page.dart` no crezca sin control. No filtra nada
/// por su cuenta: escribe la busqueda en el controlador, que es quien deriva
/// las listas.
class ExploreSearchRow extends StatefulWidget {
  const ExploreSearchRow({super.key});

  @override
  State<ExploreSearchRow> createState() => _ExploreSearchRowState();
}

class _ExploreSearchRowState extends State<ExploreSearchRow> {
  final ProjectController _controller = Get.find();
  late final TextEditingController _searchController;
  late final StreamSubscription<String> _searchSubscription;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: _controller.searchQuery.value,
    );
    // El campo es de esta vista pero la verdad esta en el controlador: cuando
    // el estado vacio limpia los filtros, el texto escrito tiene que irse con
    // ellos. La suscripcion se cancela en dispose, o seguiria escribiendo en
    // un TextEditingController ya descartado.
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.gapL,
        AppTokens.gapM,
        AppTokens.gapL,
        AppTokens.gapS,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _controller.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Buscar proyectos...',
                prefixIcon: Icon(Icons.search, color: AppColors.secondary),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.gapM),
          Obx(() {
            final int marcados = _controller.activeFilterCount;
            return OutlinedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.projectFilters),
              icon: const Icon(Icons.tune, size: 18),
              label: Text(marcados > 0 ? 'Filtros ($marcados)' : 'Filtros'),
            );
          }),
        ],
      ),
    );
  }
}

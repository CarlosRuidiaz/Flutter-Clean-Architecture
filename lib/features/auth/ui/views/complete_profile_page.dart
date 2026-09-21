import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/app_catalogs.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../viewmodels/authentication_controller.dart';

/// Paso 2 de 2 del registro: el perfil del estudiante.
///
/// Aqui se llama a `register` con todo junto, credenciales incluidas: el
/// perfil viaja en el `extra`, y `extra` solo se envia al crear la cuenta.
/// Partirlo en dos llamadas dejaria cuentas sin perfil.
///
/// Programa y habilidades salen de [AppCatalogs] y no de texto libre: si cada
/// quien escribe su variante, el emparejamiento con los proyectos se rompe.
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage>
    with UiLoggy {
  final _formKey = GlobalKey<FormState>();
  final controllerName = TextEditingController();
  final controllerBio = TextEditingController();

  final AuthenticationController authenticationController = Get.find();

  String? _programa;
  int _semestre = 1;
  final List<String> _habilidades = [];

  @override
  void dispose() {
    controllerName.dispose();
    controllerBio.dispose();
    super.dispose();
  }

  bool get _perfilCompleto => _programa != null && _habilidades.isNotEmpty;

  Future<void> _crearCuenta() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (!_formKey.currentState!.validate()) return;

    loggy.debug('SignUp paso 2: creando la cuenta con el perfil');
    final creada = await authenticationController.signUp(
      widget.email,
      widget.password,
      name: controllerName.text,
      academicProgram: _programa!,
      semester: _semestre,
      skills: List<String>.from(_habilidades),
      bio: controllerBio.text,
    );

    if (!mounted) return;
    if (creada) {
      // register con autoLogin deja la sesion abierta: se sale del registro
      // entero y Central decide a donde ir.
      Get.until((route) => route.isFirst);
    } else {
      Get.snackbar(
        'Crear cuenta',
        authenticationController.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.card,
        colorText: AppColors.ink,
      );
    }
  }

  Widget _chip({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Pill(
        label: label,
        background: selected ? selectedColor : AppColors.card,
      ),
    );
  }

  Widget _grupo({required String titulo, required List<Widget> chips}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppTokens.gapS),
        Wrap(
          spacing: AppTokens.gapS,
          runSpacing: AppTokens.gapS,
          children: chips,
        ),
        const SizedBox(height: AppTokens.gapL),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.gapL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Paso 2 de 2', style: texto.bodySmall),
              const SizedBox(height: AppTokens.gapXs),
              Text(
                'Esto es lo que ven los demás de ti, y con esto te '
                'recomendamos proyectos.',
                style: texto.bodyMedium,
              ),
              const SizedBox(height: AppTokens.gapXl),
              TextFormField(
                controller: controllerName,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Ej: Ana García',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Escribe tu nombre' : null,
              ),
              const SizedBox(height: AppTokens.gapL),
              _grupo(
                titulo: 'Programa académico',
                chips: [
                  for (final programa in AppCatalogs.academicPrograms)
                    _chip(
                      label: programa,
                      selected: _programa == programa,
                      selectedColor: AppColors.petrol,
                      onTap: () => setState(() => _programa = programa),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Semestre', style: texto.bodyLarge)),
                  Container(
                    decoration: BoxDecoration(
                      border: AppTokens.border(),
                      borderRadius: AppTokens.borderRadius,
                      color: AppColors.card,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _semestre > 1
                              ? () => setState(() => _semestre--)
                              : null,
                        ),
                        Text('$_semestre', style: texto.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _semestre < 12
                              ? () => setState(() => _semestre++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.gapL),
              TextFormField(
                controller: controllerBio,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Sobre ti (opcional)',
                  hintText: 'Una o dos líneas: qué te interesa, qué buscas.',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppTokens.gapM),
              _grupo(
                titulo: 'Tus habilidades',
                chips: [
                  for (final habilidad in AppCatalogs.skills)
                    _chip(
                      label: habilidad,
                      selected: _habilidades.contains(habilidad),
                      selectedColor: AppColors.persimmon,
                      onTap: () => setState(() {
                        if (_habilidades.contains(habilidad)) {
                          _habilidades.remove(habilidad);
                        } else {
                          _habilidades.add(habilidad);
                        }
                      }),
                    ),
                ],
              ),
              if (!_perfilCompleto)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.gapM),
                  child: Text(
                    'Elige tu programa y al menos una habilidad: sin eso no '
                    'podemos mostrarte proyectos que te sirvan.',
                    style: texto.bodySmall,
                  ),
                ),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      authenticationController.isLoading || !_perfilCompleto
                      ? null
                      : _crearCuenta,
                  child: Text(
                    authenticationController.isLoading
                        ? 'Creando cuenta...'
                        : 'Crear cuenta',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

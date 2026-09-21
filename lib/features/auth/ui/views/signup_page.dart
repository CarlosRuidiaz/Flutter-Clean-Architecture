import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/app_catalogs.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../viewmodels/authentication_controller.dart';

/// Registro: credenciales mas el perfil del estudiante.
///
/// Programa y habilidades salen de [AppCatalogs] y no de texto libre. Si cada
/// quien escribe su variante, el emparejamiento entre proyectos y estudiantes
/// deja de funcionar.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with UiLoggy {
  final _formKey = GlobalKey<FormState>();
  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  final AuthenticationController authenticationController = Get.find();

  String? _programa;
  int _semestre = 1;
  final List<String> _habilidades = [];

  @override
  void dispose() {
    controllerName.dispose();
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  bool get _perfilCompleto => _programa != null && _habilidades.isNotEmpty;

  Future<void> _signUp() async {
    final created = await authenticationController.signUp(
      controllerEmail.text,
      controllerPassword.text,
      name: controllerName.text,
      academicProgram: _programa!,
      semester: _semestre,
      skills: List<String>.from(_habilidades),
    );

    if (!mounted) return;
    if (created) {
      // Con autoLogin la sesion ya quedo abierta: Central decide a donde ir.
      Get.back();
    } else {
      Get.snackbar(
        'Registro',
        authenticationController.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.card,
        colorText: AppColors.ink,
      );
    }
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.gapM),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator,
      ),
    );
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
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.gapL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tus datos', style: texto.titleMedium),
              const SizedBox(height: AppTokens.gapM),
              _campo(
                controller: controllerName,
                label: 'Nombre completo',
                hint: 'Ej: Ana García',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Escribe tu nombre' : null,
              ),
              _campo(
                controller: controllerEmail,
                label: 'Correo institucional',
                hint: 'tunombre${AuthenticationController.dominioInstitucional}',
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Escribe tu correo';
                  if (!AuthenticationController.esCorreoInstitucional(v)) {
                    return 'Usa tu correo '
                        '${AuthenticationController.dominioInstitucional}';
                  }
                  return null;
                },
              ),
              _campo(
                controller: controllerPassword,
                label: 'Contraseña',
                hint: 'Al menos 7 caracteres',
                obscure: true,
                validator: (v) => (v == null || v.length < 7)
                    ? 'Debe tener al menos 7 caracteres'
                    : null,
              ),
              const SizedBox(height: AppTokens.gapS),
              Text('Tu perfil', style: texto.titleMedium),
              const SizedBox(height: AppTokens.gapM),
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
                  Expanded(
                    child: Text('Semestre', style: texto.bodyLarge),
                  ),
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
                      : () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_formKey.currentState!.validate()) {
                            loggy.debug('SignUp: formulario valido');
                            await _signUp();
                          }
                        },
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

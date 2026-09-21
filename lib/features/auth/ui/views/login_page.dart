import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/app_tokens.dart';
import '../viewmodels/authentication_controller.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with UiLoggy {
  final _formKey = GlobalKey<FormState>();
  // Sin valores precargados: los de la plantilla no eran institucionales y
  // hoy ni siquiera pasarian la validacion.
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  final AuthenticationController authenticationController = Get.find();

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    loggy.debug('Login: ${controllerEmail.text}');
    final loggedIn = await authenticationController.login(
      controllerEmail.text,
      controllerPassword.text,
    );
    if (!loggedIn && mounted) {
      Get.snackbar(
        'Entrar',
        authenticationController.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.card,
        colorText: AppColors.ink,
      );
    }
  }

  Future<void> _enviar() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_formKey.currentState!.validate()) await _login();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme texto = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.gapXl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Innovation Hub',
                    style: texto.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.gapS),
                  Text(
                    'Entra con tu correo institucional para ver la cartelera.',
                    style: texto.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.gapXl),
                  TextFormField(
                    controller: controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo institucional',
                      hintText:
                          'tunombre${AuthenticationController.dominioInstitucional}',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Escribe tu correo';
                      }
                      if (!AuthenticationController.esCorreoInstitucional(v)) {
                        return 'Usa tu correo '
                            '${AuthenticationController.dominioInstitucional}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTokens.gapM),
                  TextFormField(
                    controller: controllerPassword,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (v) => (v == null || v.length < 7)
                        ? 'Debe tener al menos 7 caracteres'
                        : null,
                    onFieldSubmitted: (_) => _enviar(),
                  ),
                  const SizedBox(height: AppTokens.gapXl),
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          authenticationController.isLoading ? null : _enviar,
                      child: Text(
                        authenticationController.isLoading
                            ? 'Entrando...'
                            : 'Entrar',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.gapS),
                  OutlinedButton(
                    onPressed: () => Get.to(() => const SignUpPage()),
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

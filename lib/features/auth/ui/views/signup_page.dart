import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/app_tokens.dart';
import '../viewmodels/authentication_controller.dart';
import 'complete_profile_page.dart';

/// Paso 1 de 2 del registro: solo las credenciales.
///
/// Aqui no se llama a `register`. El perfil viaja en el `extra` del registro y
/// `extra` solo se envia al crear la cuenta, asi que la cuenta no se crea
/// hasta terminar el paso 2.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with UiLoggy {
  final _formKey = GlobalKey<FormState>();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerConfirmacion = TextEditingController();

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    controllerConfirmacion.dispose();
    super.dispose();
  }

  void _continuar() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (!_formKey.currentState!.validate()) return;

    loggy.debug('SignUp paso 1: credenciales validas');
    Get.to(
      () => CompleteProfilePage(
        email: controllerEmail.text.trim(),
        password: controllerPassword.text,
      ),
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
              Text('Paso 1 de 2', style: texto.bodySmall),
              const SizedBox(height: AppTokens.gapXs),
              Text('Tus credenciales', style: texto.titleLarge),
              const SizedBox(height: AppTokens.gapS),
              Text(
                'Usa tu correo institucional. En el siguiente paso completas '
                'tu perfil.',
                style: texto.bodyMedium,
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
                  if (v == null || v.trim().isEmpty) return 'Escribe tu correo';
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
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Al menos 7 caracteres',
                ),
                validator: (v) => (v == null || v.length < 7)
                    ? 'Debe tener al menos 7 caracteres'
                    : null,
              ),
              const SizedBox(height: AppTokens.gapM),
              TextFormField(
                controller: controllerConfirmacion,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Repite la contraseña',
                ),
                validator: (v) => v != controllerPassword.text
                    ? 'Las contraseñas no coinciden'
                    : null,
                onFieldSubmitted: (_) => _continuar(),
              ),
              const SizedBox(height: AppTokens.gapXl),
              ElevatedButton(
                onPressed: _continuar,
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

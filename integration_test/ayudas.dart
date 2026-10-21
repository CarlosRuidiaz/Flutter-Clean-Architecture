import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un widget por su llave de prueba.
Finder porLlave(String llave) => find.byKey(Key(llave));

/// Toca [finder]: lo trae a la vista si esta en una lista que se desplaza y
/// espera a que termine la navegacion o la animacion que provoque.
Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Escribe [texto] en el campo de [llave], reemplazando lo que hubiera.
Future<void> escribir(WidgetTester tester, String llave, String texto) async {
  final campo = porLlave(llave);
  await tester.ensureVisible(campo);
  await tester.pumpAndSettle();
  await tester.enterText(campo, texto);
  await tester.pumpAndSettle();
}

/// Bombea frames hasta que [finder] encuentre algo, o hasta [limite].
///
/// Para lo que aparece despues de una operacion asincrona, como un aviso
/// tras un login fallido: `pumpAndSettle` puede volver antes de que la
/// operacion termine, porque mientras espera no hay frames pendientes.
Future<void> esperarA(
  WidgetTester tester,
  Finder finder, {
  Duration limite = const Duration(seconds: 5),
}) async {
  final fin = DateTime.now().add(limite);
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(fin)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Inicia sesion desde `LoginPage`, como lo haria una persona.
Future<void> iniciarSesion(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await escribir(tester, 'TextFormFieldLoginEmail', email);
  await escribir(tester, 'TextFormFieldLoginPassword', password);
  await tocar(tester, porLlave('ButtonLoginSubmit'));
}

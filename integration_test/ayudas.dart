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

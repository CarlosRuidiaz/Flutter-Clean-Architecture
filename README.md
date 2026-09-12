# Innovation Hub

Aplicación móvil para conectar estudiantes con proyectos universitarios.

Quien tiene una idea la publica en una cartelera y dice qué habilidades busca. Quien quiere participar explora las ideas publicadas, encuentra las que encajan con lo que sabe hacer y se postula. El líder del proyecto revisa las postulaciones y arma su equipo.

Proyecto del curso **Programación Móvil**, Universidad del Norte. Grupo 4.
Hecho en Flutter con GetX, siguiendo una arquitectura limpia pragmática.

**Prototipo en Figma:** https://www.figma.com/design/WffkIQ3gkDkkGvudgIFaSE/Semana-5-prototipo

---

## Qué hace

- **Cartelera de proyectos.** Lista de ideas publicadas, cada una con su etapa, el programa académico, cuántos miembros tiene de los que busca y qué habilidades necesita. Hay una pestaña que filtra por las habilidades del estudiante y otra que muestra todo.
- **Detalle de un proyecto.** El problema que resuelve, la descripción, el equipo actual y las habilidades que faltan. Desde ahí se postula.
- **Publicar una idea.** Un formulario en tres pasos: lo esencial, el equipo que se busca y contexto opcional.
- **Seguimiento de la postulación.** Ver si sigue en revisión o si ya fue aceptada, y cancelarla mientras siga pendiente.
- **Gestión de postulantes.** Quien lidera un proyecto ve quién se postuló, con su programa, semestre y habilidades, y acepta o rechaza. También puede cerrar el reclutamiento.
- **Perfil del estudiante**, con su programa, semestre y habilidades.

---

## Cómo ejecutarlo

Necesitas el SDK de Flutter instalado. Luego, desde la raíz del proyecto:

```bash
flutter pub get
```

La primera ejecución necesita conexión a internet: las tipografías se descargan una vez y quedan en caché.

### En un emulador de Android

Abre el emulador desde Android Studio, en **Device Manager**, y espera a que arranque del todo. Después:

```bash
flutter devices     # para confirmar que aparece
flutter run
```

Si hay un solo dispositivo conectado, `flutter run` lo toma directamente. Si hay varios, `flutter run -d <id>` con el identificador que muestre `flutter devices`.

### En el navegador

```bash
flutter run -d chrome
```

Útil para iterar rápido sobre la interfaz, porque recompila en segundos.

### Notas

No hay inicio de sesión todavía: la aplicación entra directo a la cartelera con un perfil de estudiante de ejemplo.

Los datos son locales y de prueba. Lo que publiques o postules se mantiene mientras la aplicación siga abierta y se pierde al cerrarla, porque todavía no hay servidor ni almacenamiento permanente.

---

## Arquitectura

La aplicación está organizada por funcionalidad, y cada una se parte en tres capas donde **cada capa solo conoce a la de adentro**:

```
Vista  →  Controlador  →  Repositorio  →  Fuente de datos
       └─── ui/ ───┘   └─ domain/ ─┘   └──── data/ ────┘
```

Entre cada paso hay una interfaz, no una clase concreta. Eso tiene tres consecuencias prácticas:

- Las reglas del negocio no dependen de Flutter ni de dónde vengan los datos.
- Se puede probar un controlador sin base de datos, sin red y sin pantalla.
- Cambiar los datos de prueba locales por un servidor real es escribir una clase nueva y cambiar una línea, sin tocar ninguna pantalla.

```
lib/
├── main.dart          arranque y registro de las dependencias
├── core/              tema visual, rutas y widgets compartidos
└── features/
    └── <nombre>/
        ├── domain/    entidades y contratos
        ├── data/      fuentes de datos y repositorios
        └── ui/        controladores y pantallas
```

Es una versión pragmática de la arquitectura limpia: en lugar de un caso de uso por cada acción, esa lógica vive en el controlador. Reduce la cantidad de archivos sin perder la separación entre capas.

### Identidad visual

El diseño sigue el prototipo de Figma: fondo de papel crema, tarjetas con borde fino y sombra dura sin difuminado, chips en píldora y un color por cada etapa de un proyecto. Los valores están centralizados en un solo archivo, así que el aspecto de toda la aplicación se ajusta desde ahí.

---

## Estado actual

Todo el flujo descrito arriba está implementado y funcionando con datos locales de prueba: explorar la cartelera, ver el detalle de un proyecto, publicar una idea, postularse, seguir el estado de la postulación y gestionar los postulantes de un proyecto propio.

El inicio de sesión está construido pero desconectado, a la espera del servidor.

## Qué falta

- Conectar un servidor. Hoy todos los datos son locales y de prueba.
- Guardar los datos para que sobrevivan al cerrar la aplicación, y que funcione sin conexión.
- Activar el inicio de sesión.
- Notificaciones, espacio de trabajo del proyecto y el resto de pantallas del prototipo.

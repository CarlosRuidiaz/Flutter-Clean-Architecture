# Arreglos para `feat/navegacion`

Hola. Revisamos tu rama `feat/navegacion` (último commit `bccda96`) y no compila:
`flutter analyze` da **25 errores** y `flutter test` no puede ni arrancar. La
causa principal es que falta `my_projects_view.dart`, que `home_page.dart` ya
importa, y también `CompactProjectCard`, que usa el perfil.

**Tu rama no la tocamos.** Hicimos los arreglos en otra aparte,
`feat/navegacion-completa`, para tener un respaldo. La idea es que los
apliques tú en la tuya, si te da tiempo. Si no alcanzas, usamos la nuestra.

Abajo va cada arreglo en el mismo orden de los commits, con el archivo y qué
cambiar. Al terminar, `flutter analyze` debe decir `No issues found!` y
`flutter test` debe pasar completo (en la nuestra: **150 pruebas**).

Decisiones que ya tomamos, para que no tengas que adivinarlas:

- El color de acento es **`AppColors.gold`**, porque `AppColors.sun` no existe.
- El contador de "proyectos activos" del perfil **no cuenta los proyectos en
  etapa `finished`**.

---

## 1. Errores de compilación

**`lib/features/my_projects/my_projects_dependencies.dart`**

Los imports suben un nivel de más. El archivo está en `features/my_projects/`,
así que es `../`, no `../../`:

```dart
import '../application/domain/repositories/i_application_repository.dart';
import '../auth/domain/repositories/i_auth_repository.dart';
import '../profile/domain/repositories/i_profile_repository.dart';
import '../project/domain/repositories/i_project_repository.dart';
```

**`lib/features/my_projects/ui/viewmodels/my_projects_controller.dart`**

`profile.id` es `String?` y los repositorios piden `String`. Guarda el id una
sola vez y sal si viene nulo:

```dart
final myId = profile.id;
if (myId == null) {
  _clearData();
  return;
}
final created = allProjects.where((p) => p.leaderId == myId).toList();
final myApps = await appRepo.getMyApplications(myId);
```

**`lib/features/profile/ui/views/profile_view.dart`**

- `AppColors.sun` → `AppColors.gold`.
- `side: AppTokens.border()` devuelve un `Border` y `side` pide un
  `BorderSide`. Cámbialo por:
  ```dart
  side: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
  ```

**Pruebas** (`my_projects_controller_test.dart` y `profile_view_test.dart`)

- `AuthenticationUser(...)` va **sin `const`**, porque su constructor no es
  const.
- En el repositorio falso de perfil, quita el `@override` de `saveProfile`:
  la interfaz no tiene ese método.
- Los `import` van arriba del todo. Había uno después de una clase y eso no
  compila.

## 2. La vista que falta: `MyProjectsView` y `CompactProjectCard`

**Nuevo: `lib/features/my_projects/ui/views/widgets/compact_project_card.dart`**

- `CompactProjectCard({required Project project, Widget? bottomWidget, Widget? trailing, VoidCallback? onTap})`.
- Se arma con `PaperCard` (margen derecho e inferior igual a `shadowOffset`,
  para que la sombra no se corte), el título, un `StageChip` y "N de M
  miembros".
- `profile_view.dart` debe importarlo de esta ruta.

**Nuevo: `lib/features/my_projects/ui/views/my_projects_view.dart`**

- `MyProjectsView({VoidCallback? onExplore})`, con un `DefaultTabController`
  de dos pestañas: **"Creados por mí"** y **"Donde participo"**.
- Cada lista va dentro de un `RefreshIndicator` que llama a
  `controller.reload`.
- Al tocar una tarjeta se abre `Get.toNamed(AppRoutes.projectDetail, ...)` y,
  al volver, recarga.
- En "Creados por mí", cada tarjeta lleva un `Pill` con `'1 pendiente'` o
  `'N pendientes'`. Sale también con 0.
- Estados vacíos:
  - Sin proyectos creados: "Todavía no has creado proyectos", con el botón
    "Publicar una idea", que va a `createIdea` y recarga al volver.
  - Sin participaciones: "Todavía no participas en ningún proyecto", con el
    botón "Explorar proyectos", que llama a `onExplore`.

**`home_page.dart`**

Los hijos del `IndexedStack` ya no pueden ser `const`, porque la pestaña
recibe:

```dart
MyProjectsView(onExplore: () => setState(() => _currentIndex = 0))
```

**`my_projects_controller.dart`**

Añade `int pendingFor(String? projectId)`, que la vista usa para leer el
conteo.

**Pruebas:** `profile_view_test.dart` y `project_filters_page_test.dart`

- **No llames a `onInit()` a mano.** `Get.put` ya lo llama, así que el
  controlador se suscribía dos veces.
- Dentro del cuerpo del `testWidgets`, antes de `pumpWidget`, haz
  `await Get.find<MyProjectsController>().reload();`. La carga que arranca en
  `setUp` corre fuera del reloj falso del test y terminaba después de pintar,
  por eso salía "0 proyectos activos".
- En `project_filters_page_test.dart` registra `IAuthRepository`,
  `IApplicationRepository` y `MyProjectsController`. El `IndexedStack`
  construye todas las pestañas a la vez y, sin ellos, falla con "not found".

## 3. Paralelo y errores visibles

**`my_projects_controller.dart`**

- Los pendientes de cada proyecto se piden en paralelo, no uno tras otro:
  ```dart
  final conteos = await Future.wait(created.map((p) async {
    final apps = await appRepo.getApplicationsFor(p.id!);
    return MapEntry(p.id!, apps.where((a) => a.isPending).length);
  }));
  pendingApplicationsCount.assignAll(Map.fromEntries(conteos));
  ```
- `RxString error`: se vacía (`''`) al empezar cada carga y en el `catch` se
  llena con `errorMessage(e)`. Así un fallo ya no se ve como "no tienes
  proyectos".
- `int get activeProjectsCount`: creados más los que participas, **sin
  `ProjectStage.finished`** y sin repetir el mismo id.

**`my_projects_view.dart`**

Si `error` no está vacío, muestra "No pudimos cargar tus proyectos" con un
botón "Reintentar".

**`profile_view.dart`**

- El spinner solo aparece mientras `isLoading`. Si el perfil llega nulo,
  muestra "No pudimos cargar tu perfil" con "Reintentar"
  (`getCurrentProfile`). Antes se quedaba girando para siempre.
- Usa `activeProjectsCount`: "1 proyecto activo" o "N proyectos activos".
- Las iniciales son dos letras. "Juan Pérez" → "JP".

**`home_page.dart`**

- El botón "Crear" abre `createIdea` sin cambiar de pestaña. Al volver llama
  a `Get.find<MyProjectsController>().reload()`, si está registrado.
- `Colors.transparent` → `null`. Acordamos no usar colores literales.

**Pruebas nuevas**

- `test/features/my_projects/my_projects_robustez_test.dart`: como máximo 3
  peticiones en vuelo a la vez, que el error se muestre y se limpie, que los
  terminados no cuenten, y el estado de error de la vista.
- `test/features/profile/profile_view_error_test.dart`: con el perfil nulo se
  ve el mensaje y no el spinner.
- `test/features/my_projects/my_projects_view_test.dart`: 7 pruebas de la
  vista.

## 4. Pruebas de la barra inferior

**Nuevo: `test/features/project/barra_inferior_test.dart`**, con 4 pruebas:

- arranca en la cartelera;
- los cinco destinos;
- "Crear" no cambia de pestaña;
- el `IndexedStack` conserva el estado al ir y volver.

## 5. Lo que se vio al probarla en Chrome

**`home_page.dart`**

- Con `width: 60` se cortaban "Mis proyectos" y "Notificaciones".
- Cambios: envuelve cada `_NavBarItem` y el `_CreateActionItem` en
  `Expanded(child: InkWell(...))`, quita el `width: 60` y quita el
  `mainAxisAlignment: MainAxisAlignment.spaceEvenly` del `Row`.

**`my_projects_view.dart`**

- Una píldora de pendientes en dorado se confundía con el chip de la etapa
  Idea, que es del mismo color.
- Cambio: el fondo de la píldora es `AppColors.card` y el color del texto
  marca la diferencia: `AppColors.persimmon` si hay pendientes,
  `AppColors.secondary` si no.

## 6. La búsqueda pasaba a la siguiente cuenta

- Si la cuenta A buscaba "movilidad", cerraba sesión y entraba la B, la B veía
  la cartelera ya filtrada.
- En `lib/features/project/ui/viewmodels/project_controller.dart`, dentro del
  listener de `sessionChanges`, en la rama sin sesión:
  ```dart
  } else {
    _profile.value = null;
    clearFilters();
  }
  ```
- La prueba va en `project_controller_test.dart`: "cerrar sesion borra la
  busqueda y los filtros".

---

## Cómo comprobar

```bash
flutter analyze   # No issues found!
flutter test      # All tests passed!
```

Lo probamos en Chrome con dos cuentas de sesión simulada, porque desde el
entorno de pruebas no se llega a Roble. Pasaron las 27 comprobaciones del
recorrido completo: publicar, postularse, aceptar, cambiar de cuenta, y que
los pendientes y el contador se actualicen.

Queda un detalle **después del merge**, que no es de tu rama. Al arrancar, los
controladores cargan dos veces: una en `onInit` y otra porque
`sessionChanges` emite al suscribirse. No rompe nada, solo duplica
peticiones.

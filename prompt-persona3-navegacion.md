# Persona 3 · Navegación: barra inferior, "Mis proyectos" y perfil

Estás en el repositorio `Flutter-Clean-Architecture`, una app Flutter del curso de Programación Móvil
(Universidad del Norte). Arquitectura por features con GetX: `Vista → Controlador → Repositorio → Fuente`,
sin casos de uso. Cada feature tiene un `<feature>_dependencies.dart`, que es el único archivo que nombra
clases concretas. El paquete se llama `f_clean_template` y no se renombra.

Hoy la barra inferior de la app tiene cinco botones, pero solo funciona "Crear". Tu trabajo es que
**funcionen todos**, y construir las dos pantallas que faltan detrás: **"Mis proyectos"** y **"Perfil"**.

En las pruebas de usuario, 4 de 5 personas no volvieron a encontrar la idea que habían publicado. "Mis
proyectos" es la respuesta a eso.

Otras personas están trabajando a la vez en el login, en los datos contra el servidor y en el espacio de
trabajo de cada proyecto. Por eso esta tarea **no cambia ningún contrato, repositorio ni fuente de datos**:
solo lee lo que ya existe.

## Autoría: los commits son de quien trabaja, y Claude no es coautor

Este repositorio es una entrega académica. **Cada commit queda a nombre de la persona que
está trabajando**, que es la identidad ya configurada en git de esta máquina, y **Claude no
aparece por ningún lado**: ni como autor, ni como coautor, ni en el cuerpo del mensaje.

Ya pasó una vez y hubo que reescribir la historia de `main` para quitarlo, así que trátalo
como un requisito duro.

**1. Deja la identidad de git como está.** Antes del primer commit míralas y dime cuáles son,
solo para dejar constancia:

    git config user.name
    git config user.email

Si viniera vacío, o fuera un nombre de máquina o de asistente en vez del de una persona,
**para y avísame**. No lo configures tú.

**2. No alteres la autoría de ningún commit.** Sin excepciones: nada de `git commit --author=...`,
ni `git -c user.name=... commit`, ni cambiar `git config`, ni variables `GIT_AUTHOR_*` o
`GIT_COMMITTER_*`. Commitea normal.

**3. Nada de coautoría ni de pies de atribución.** Ni `Co-Authored-By`, ni `Claude-Session`, ni
`Generated with Claude Code`, ni el emoji del robot, ni ninguna variante. El mensaje termina
donde termina la descripción del cambio.

**4. Ninguna mención a Claude dentro del repositorio.** Ni en comentarios, ni en el README, ni
en nombres de rama.

**5. Verifica después de cada commit** con `git log -1 --format="%an <%ae> | %s%n%b"`. Si algo
no cuadra, para y avísame.

**6. No crees nada fuera del repositorio local.** Ni pull requests, ni issues, ni `gh`, ni push.

## Reglas permanentes

- Todo en español: commits, comentarios del código y respuestas.
- Formato de commit: `tipo(alcance): descripción en minúsculas`.
- Archivos en UTF-8 sin BOM.
- Verifica antes de afirmar. No des por bueno nada que no hayas comprobado leyendo el archivo o corriendo
  el comando.
- Si una decisión no está cubierta aquí, dame tu recomendación razonada y espera a que yo decida.
- Al repositorio va código y nada más: ni documentos de proceso ni informes.
- Los comandos de `flutter` se corren desde la raíz del repositorio.
- Ni un color literal en las pantallas: todo sale de `AppColors`, `AppStageColors` o `Theme.of(context)`.
- No borres `lib/features/product/`, no quites `flex_color_scheme` del `pubspec.yaml` y no cambies el orden
  de los `register*()` en `main.dart`.

---

## Punto de partida

Crea la rama `feat/navegacion` desde `main` actualizado (`git pull` en `main` primero).

**Solo tocas estos archivos**, para no chocar con los demás:

- `lib/features/project/ui/views/home_page.dart`, y archivos nuevos en `lib/features/project/ui/views/`
- `lib/features/my_projects/` (feature nuevo)
- `lib/features/profile/ui/views/profile_view.dart` (archivo nuevo. No modifiques ningún otro archivo de
  `profile`)
- `lib/main.dart`, **una sola línea**: `registerMyProjects();` justo después de `registerManagement();`
- `test/features/my_projects/**`, `test/features/project/home_page_test.dart` y
  `test/features/profile/profile_view_test.dart`

**No toques** `central.dart`, `auth`, los modelos, ni nada de `data/` en ningún feature. Tampoco
`project_detail_page.dart`, que lo está cambiando otra persona. Si crees que hace falta, para y explícame
por qué.

## Lo que se copia del prototipo y lo que no

Del prototipo se copia **cómo funciona algo**, no sus textos exactos ni sus datos de ejemplo. Los colores,
tipografías y componentes salen del sistema visual que ya existe: `AppColors`, `AppTokens`, `PaperCard`,
`Pill`, `ProjectCard` y `StageChip`.

## Qué hay que hacer

### 1. La barra inferior

Destinos, en este orden, todos con ícono y texto: `Inicio` · `Mis proyectos` · `Crear` · `Notificaciones`
· `Perfil`.

- `HomePage` pasa a ser **el contenedor con la barra**. Su contenido actual (las dos pestañas de la
  cartelera) se mueve, tal cual, a un widget nuevo `CarteleraView` en `lib/features/project/ui/views/`.
  La clase se sigue llamando `HomePage` porque `central.dart` la usa y ese archivo es de otra persona.
- El cuerpo cambia con un `IndexedStack`, para que cada pestaña conserve su estado al ir y volver.
- `Crear` **no cambia de pestaña**: abre la ruta `AppRoutes.createIdea`, igual que ahora.
- Como en el prototipo, `Crear` va destacado en el centro: un cuadrado oscuro con el `+` y el texto
  debajo. El destino activo se marca con una raya corta en persimmon bajo su texto.
- `Notificaciones` muestra por ahora un estado vacío honesto: "Todavía no tienes notificaciones". Las
  notificaciones reales llegan más adelante.
- Quita el `TODO` que hay sobre la barra.
- Hoy la barra superior de `HomePage` tiene un ícono de cerrar sesión que abre una hoja de confirmación
  (`_confirmarCierreDeSesion`). **Muévela a la vista de perfil** y quita el ícono de arriba: en el
  prototipo cerrar sesión no está en la cartelera.

### 2. "Mis proyectos"

Feature nuevo `lib/features/my_projects/`, **sin `domain/` ni `data/`**, igual que `management`: no tiene
entidad propia, es otro punto de vista sobre proyectos y postulaciones.

```
lib/features/my_projects/
├── my_projects_dependencies.dart
└── ui/
    ├── viewmodels/my_projects_controller.dart
    └── views/my_projects_view.dart
```

**El controlador** recibe `IProjectRepository`, `IApplicationRepository`, `IProfileRepository` e
`IAuthRepository`. Sigue el
molde de los demás controladores: `with UiLoggy`, `loggy.debug` al entrar en cada método e `isLoading`
alrededor de la carga. Calcula dos listas:

- **Creados por mí**: los proyectos cuyo `leaderId` es el `id` del perfil actual. De cada uno, cuántas
  postulaciones `pending` tiene.
- **Donde participo**: los proyectos a los que el estudiante tiene una postulación `accepted`.

La regla de qué va en cada lista vive en el controlador, no en la vista. Regístralo en
`my_projects_dependencies.dart` con `Get.lazyPut(..., fenix: true)`, por el mismo motivo que
`registerManagement`.

**Hay que escuchar los cambios de sesión.** El controlador vive mientras la app está abierta
(`fenix: true`), así que si alguien cierra sesión y entra otra cuenta, seguiría mostrando los proyectos de
la anterior. `ProjectController` y `ProfileController` ya resuelven esto: reciben `IAuthRepository` y se
suscriben a `sessionChanges`. Haz lo mismo: con sesión nueva recarga, sin sesión vacía las listas, y
cancela la suscripción en `onClose`. Para las pruebas ya existe `test/features/auth/fake_auth_repository.dart`.

**La vista** lleva el título "Mis proyectos" y dos pestañas, "Creados por mí" y "Donde participo".

- Cada proyecto va en una tarjeta compacta sobre `PaperCard`: título, etiqueta de etapa (`StageChip`) y
  la línea "programa · 4 de 6 miembros". Al tocarla abre el detalle (`AppRoutes.projectDetail`). La
  miniatura de imagen del prototipo no va, porque los proyectos todavía no tienen imágenes.
- En "Creados por mí", cada tarjeta lleva además una píldora con borde persimmon que **siempre** aparece:
  "2 postulaciones pendientes", o "Sin postulaciones pendientes" cuando no hay. Así el líder sabe de un
  vistazo dónde tiene que responder.
- Cada pestaña tiene su estado vacío. En "Creados por mí" el estado vacío ofrece ir a crear una idea. En
  "Donde participo" ofrece ir a la cartelera.
- **Los datos cambian desde otras pantallas** (aceptar a alguien, crear una idea), así que la lista se
  recarga cada vez que el usuario entra a la pestaña, no solo la primera vez.

La pestaña "Siguiendo" del prototipo **no va todavía**: seguir proyectos aún no existe en la app.

### 3. "Perfil"

`lib/features/profile/ui/views/profile_view.dart`, que lee de `ProfileController` (ya existe, no lo
cambies):

- Un círculo en oro con las iniciales del nombre. A su lado el nombre en la tipografía de titulares, y
  debajo "programa · 6.º semestre" y, en persimmon, "2 proyectos activos".
- Una sección "Habilidades e intereses" con las habilidades como chips con `Pill`.
- Una sección "Proyectos" con las mismas tarjetas compactas de "Mis proyectos". En lugar de la píldora,
  cada una dice el papel: "Líder · 3 de 5 miembros" o "Participa · 3 de 5 miembros".
- Al final, un botón "Cerrar sesión" que abre la hoja de confirmación que moviste desde `HomePage`. Esa
  hoja ya llama a `AuthenticationController.logOut()`, y `Central` devuelve al login solo.

El número de proyectos activos y la sección "Proyectos" salen de `MyProjectsController`, que ya calcula
las dos listas. No repitas esa lógica en la vista de perfil.

Biografía, foto y "Editar perfil" **no van todavía**. La biografía la está añadiendo al perfil otra
persona, y las fotos necesitan un almacenamiento que no está conectado.

## Pruebas

- `MyProjectsController` con repositorios falsos: qué proyectos caen en cada lista y el número de
  pendientes. Mira `test/features/management/management_controller_test.dart` como molde.
- La barra: tocar cada destino muestra la vista correcta, y "Crear" abre la ruta de crear idea.
- La vista de perfil pinta nombre, programa, habilidades y el número de proyectos activos.
- Al cambiar la sesión, `MyProjectsController` recarga o vacía sus listas.
- Todas las pruebas existentes siguen pasando. Si `home_page_test.dart` necesita ajustes por el cambio a
  `CarteleraView`, hazlos y dime cuáles.

## Commits sugeridos

```
refactor(project): la cartelera pasa a su propia vista
feat(project): la barra inferior lleva a cada seccion
feat(my_projects): proyectos creados y donde participo
feat(profile): pantalla de perfil con cierre de sesion
test(my_projects): pruebas del controlador y de la barra
```

## Verificación

1. `flutter analyze` y `flutter test` sin errores.
2. `flutter run`, en el emulador de Android o con `-d chrome`:
   - Los cinco botones de la barra hacen lo que deben.
   - La app pide login con Roble. Regístrate con tu propio correo `@uninorte.edu.co`. Los proyectos de
     prueba no son tuyos, así que "Creados por mí" empieza vacío y muestra su estado vacío.
   - Crear una idea y encontrarla en "Creados por mí" sin reiniciar la app.
   - Para "Donde participo" hacen falta dos cuentas, sin cerrar la app entre pasos: con la cuenta B te
     postulas a la idea de A, cierras sesión, entras con A y la aceptas, cierras sesión y entras con B. La
     idea aparece en "Donde participo" de B. Si pides ayuda a un compañero para la cuenta B, que la
     registre él con su correo.
   - Cerrar sesión desde el perfil y entrar con otra cuenta: "Mis proyectos" no puede seguir mostrando los
     de la cuenta anterior.
3. Antes de terminar, `git merge main` para traer lo que hayan subido los demás. Si hay conflicto en
   `main.dart`, se conservan las dos líneas.

Al terminar, dame los commits con su autor, los archivos creados y modificados, el resultado de `analyze`
y `test`, y lo que viste al probar. **No empujes.**

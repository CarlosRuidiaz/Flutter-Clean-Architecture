# Feature `profile` · Persona 1 — dominio y datos

**Rama:** `feat/profile-dominio`
**Tu mitad:** la de adentro. **Dart puro: no vas a escribir ni un widget.**
**Tu pareja** hace el controlador y el widget, y programa contra la interfaz que tú escribas.

---

## Qué es este feature y por qué existe

En el prototipo, el homepage tiene esta línea justo debajo del título:

```
Para tus habilidades
Proyectos que buscan: Investigación · Diseño UX
```

Esas habilidades **no son del proyecto: son del estudiante que está mirando la app.** Es una entidad distinta, con su propia vida, y hoy no existe en ninguna parte del código.

Ese es tu feature: el estudiante actual. Es más pequeño que `project` —una entidad, dos contratos, una fuente, un controlador y un widget— pero recorre exactamente la misma cadena, así que aprendes lo mismo.

Más adelante crece hasta ser la pantalla `13 Perfil de estudiante` del prototipo.

---

## La arquitectura en un minuto

```
Widget → Controlador → IProfileRepository → Repositorio → IProfileSource → Fuente
       └── tu pareja ──┘   └───────────────── tú ───────────────────────────┘
```

Cada flecha atraviesa una **interfaz**, no una clase concreta. Por eso tu pareja puede escribir su controlador completo hoy mismo, aunque tú no hayas empezado.

**Lo primero que debes hacer:** escribir la entidad y los dos contratos, commitearlos y avisarle. Son 35 líneas y la desbloquean por completo.

---

## Archivo 1 · `lib/features/profile/domain/models/profile.dart`

```dart
class Profile {
  Profile({
    this.id,
    required this.fullName,
    required this.academicProgram,
    required this.semester,
    required this.skills,
  });

  String? id;
  String fullName;
  String academicProgram;
  int semester;
  List<String> skills;

  bool get isComplete => fullName.isNotEmpty && skills.isNotEmpty;
}
```

### Lo que hay que entender

**No tiene ni un `import`.** Es Dart puro: no sabe que existe Flutter, ni GetX, ni una pantalla. Si le añades `import 'package:flutter/...'`, la arquitectura está rota. Nadie te lo impide al compilar — eso se revisa leyendo los imports en los PRs.

**`isComplete` vive aquí.** El criterio para saber dónde va una función es: *¿esto sería verdad si no hubiera pantalla?* "Un perfil está incompleto si le faltan el nombre o las habilidades" es una regla del negocio, no de la interfaz. En cambio formatear las habilidades como `"Investigación · Diseño UX"` es presentación, y eso lo hace tu pareja.

Ese getter no lo usa nadie esta semana, y está bien: es lo que va a alimentar la pantalla `03 Completar perfil` más adelante.

**Sin `fromJson`/`toJson` todavía.** Los datos van quemados en Dart. Se añaden cuando entre Roble y se sepa la forma real de los datos.

---

## Archivo 2 · `lib/features/profile/domain/repositories/i_profile_repository.dart`

```dart
import '../models/profile.dart';

abstract class IProfileRepository {
  Future<Profile> getCurrentProfile();
}
```

`abstract class` = **no tiene cuerpo**. Dice qué se puede pedir, nunca cómo se consigue.

Fíjate en una diferencia con el otro feature: aquí devuelves **un** `Profile`, no una lista. Solo hay un estudiante actual.

**Este es el archivo que le importa a tu pareja.** Con él ya puede escribir su controlador entero.

Un solo método. Nada de `updateProfile` hasta que exista una pantalla que lo necesite.

---

## Archivo 3 · `lib/features/profile/data/datasources/i_profile_source.dart`

```dart
import '../../domain/models/profile.dart';

abstract class IProfileSource {
  Future<Profile> getCurrentProfile();
}
```

Sí, es casi idéntico al anterior. Se mantienen los dos.

`IProfileRepository` vive en `domain/` y dice **lo que la app necesita**. `IProfileSource` vive en `data/` y dice **lo que una fuente sabe traer**. Hoy coinciden porque hay una sola fuente.

Se separan con el requisito de **caché offline**: "¿devuelvo lo de la red o lo guardado?" no lo puede decidir una fuente, porque solo conoce un origen. Lo decide el repositorio.

**Aquí para y commitea.** Avisa a tu pareja.

---

## Archivo 4 · `lib/features/profile/data/datasources/local/local_profile_source.dart`

```dart
import '../../../domain/models/profile.dart';
import '../i_profile_source.dart';

class LocalProfileSource implements IProfileSource {
  @override
  Future<Profile> getCurrentProfile() async {
    return Profile(
      id: '1',
      fullName: 'Carlos Ruidíaz',
      academicProgram: 'Ingeniería de Sistemas',
      semester: 8,
      skills: ['Investigación', 'Diseño UX'],
    );
  }
}
```

**Molde:** `lib/features/product/data/datasources/local/local_product_source.dart`. El tuyo es mucho más simple: ese lee de preferencias, el tuyo devuelve un objeto literal.

Las dos habilidades **deben coincidir con lo que dice el prototipo** — `Investigación` y `Diseño UX` — porque son las que van a aparecer en la línea del homepage.

### Dos detalles

**`implements IProfileSource`** = "me comprometo a cumplir ese contrato". Si te falta un método o cambias una firma, Dart no compila.

**El `async` y el `Future` sobran hoy.** **Déjalos.** El contrato los pide para que el día que esto sea una llamada a Roble no cambie nada más arriba.

---

## Archivo 5 · `lib/features/profile/data/repositories/profile_repository.dart`

```dart
import '../../domain/models/profile.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/i_profile_source.dart';

class ProfileRepository implements IProfileRepository {
  ProfileRepository(this.source);

  final IProfileSource source;

  @override
  Future<Profile> getCurrentProfile() async => await source.getCurrentProfile();
}
```

**Molde:** `lib/features/product/data/repositories/product_repository.dart`.

Sí, seis líneas y hoy solo reenvía la llamada. Es el sitio reservado para la lógica que aún no existe: la caché offline va aquí.

Fíjate en el tipo del campo: `IProfileSource`, la **interfaz**, no `LocalProfileSource`. Por eso el día que exista una fuente que hable con Roble, este archivo no se toca.

---

## Archivo 6 · `test/features/profile/local_profile_source_test.dart`

El enunciado pide que la app sea **testeable**. Esto es la prueba, y es Dart puro.

```dart
void main() {
  group('LocalProfileSource', () {
    test('devuelve un perfil con nombre y programa', () async { /* ... */ });
    test('devuelve al menos una habilidad', () async { /* ... */ });
    test('el perfil de prueba esta completo', () async {
      // comprueba isComplete
    });
  });
}
```

**Molde:** `test/features/auth/authentication_source_service_test.dart`, que dejó el profesor. Léelo antes: es corto y enseña cómo se estructura un test en Dart.

---

## Comprobar y commitear

```
flutter analyze     → "No issues found"
flutter test        → tus pruebas en verde
```

No puedes correr la app: tu código no está conectado. Lo conecta tu pareja al final.

```
git checkout main && git pull
git checkout -b feat/profile-dominio

git add lib/features/profile/domain/
git commit -m "feat(profile): entidad Profile y contrato del repositorio"

git add lib/features/profile/data/datasources/i_profile_source.dart
git commit -m "feat(profile): contrato IProfileSource"
# --> avisa a tu pareja aqui, ya puede empezar

git add lib/features/profile/data/datasources/local/local_profile_source.dart
git commit -m "feat(profile): fuente local con el estudiante de prueba"

git add lib/features/profile/data/repositories/profile_repository.dart
git commit -m "feat(profile): ProfileRepository sobre IProfileSource"

git add test/features/profile/
git commit -m "test(profile): pruebas de la fuente local y de isComplete"

git push -u origin feat/profile-dominio
```

PR contra `main`. **Tu PR mergea antes que el de tu pareja**, porque su archivo de cableado nombra tus clases.

Te revisa tu pareja.

---

## No toques

La carpeta `lib/features/project/` es de la otra pareja. Y `lib/main.dart` y `lib/central.dart` ya están listos.

Como tu feature es el más pequeño de los dos, cuando termines ofrécele ayuda a la pareja de `project`: su carril de vistas es el de más volumen.

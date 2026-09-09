# Implementation Plan - Profile Feature (Domain & Data)

Implement the `profile` feature's Domain and Data layers as specified in `profile-1-dominio-y-datos.md`. This follow Clean Architecture principles, keeping the domain layer pure Dart and the data layer responsible for providing data from a local source.

## Proposed Changes

### Domain Layer

#### [NEW] [profile.dart](file:///D:/HW%20UNINORTE/8VO%20SEMESTRE/Movil/Flutter-Clean-Architecture/lib/features/profile/domain/models/profile.dart)
- Create the `Profile` entity with fields: `id`, `fullName`, `academicProgram`, `semester`, and `skills`.
- Include a getter `isComplete`.

#### [NEW] [i_profile_repository.dart](file:///D:/HW%20UNINORTE/8VO%20SEMESTRE/Movil/Flutter-Clean-Architecture/lib/features/profile/domain/repositories/i_profile_repository.dart)
- Define the `IProfileRepository` interface with `getCurrentProfile()`.

---

### Data Layer

#### [NEW] [i_profile_source.dart](file:///D:/HW%20UNINORTE/8VO%20SEMESTRE/Movil/Flutter-Clean-Architecture/lib/features/profile/data/datasources/i_profile_source.dart)
- Define the `IProfileSource` interface for data retrieval.

#### [NEW] [local_profile_source.dart](file:///D:/HW%20UNINORTE/8VO%20SEMESTRE/Movil/Flutter-Clean-Architecture/lib/features/profile/data/datasources/local/local_profile_source.dart)
- Implement `IProfileSource` returning a hardcoded `Profile` object ('Carlos Ruidíaz', etc.).

#### [NEW] [profile_repository.dart](file:///D:/HW%20UNINORTE/8VO%20SEMESTRE/Movil/Flutter-Clean-Architecture/lib/features/profile/data/repositories/profile_repository.dart)
- Implement `IProfileRepository` using `IProfileSource`.

---

### Testing

#### [NEW] [local_profile_source_test.dart](file:///D:/HW%20UNINORTE/8VO%20SEMESTRE/Movil/Flutter-Clean-Architecture/test/features/profile/local_profile_source_test.dart)
- Implement unit tests for `LocalProfileSource` and `Profile` entity logic (`isComplete`).

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no linting or type errors.
- Run `flutter test test/features/profile/local_profile_source_test.dart` to verify the implementation.

/// Vocabulario cerrado de la aplicacion. Que las habilidades salgan de una
/// lista y no de un campo de texto es lo que permite emparejar proyectos con
/// estudiantes: dos personas que escriben la misma habilidad de dos formas
/// distintas no harian match nunca.
///
/// Dart puro: no importa Flutter, asi que no rompe la regla de que `core` no
/// dependa de ningun feature. Es una lista de textos y nada mas.
///
/// Ningun otro archivo escribe una habilidad, un tag o un programa a mano.
/// Anadir uno el dia de manana es tocar solo este archivo.
///
/// Cada valor tiene ademas su constante con nombre. Quien siembra datos de
/// prueba la usa en vez del indice de la lista: `skills[5]` cambia de
/// significado en silencio el dia que alguien reordene, y una constante no.
///
/// Cuando entre el backend, estas listas las servira el servidor.
abstract final class AppCatalogs {
  static const String skillUx = 'Diseño UX';
  static const String skillWeb = 'Desarrollo web';
  static const String skillPython = 'Python';
  static const String skillResearch = 'Investigación';
  static const String skillMarketing = 'Marketing';
  static const String skillData = 'Análisis de datos';
  static const String skillManagement = 'Gestión';

  static const List<String> skills = [
    skillUx,
    skillWeb,
    skillPython,
    skillResearch,
    skillMarketing,
    skillData,
    skillManagement,
  ];

  static const String tagEducation = 'Educación';
  static const String tagTutoring = 'Tutorías';
  static const String tagSustainability = 'Sostenibilidad';
  static const String tagSocial = 'Social';
  static const String tagCommunity = 'Comunidad';
  static const String tagTechnology = 'Tecnología';

  static const List<String> tags = [
    tagEducation,
    tagTutoring,
    tagSustainability,
    tagSocial,
    tagCommunity,
    tagTechnology,
  ];

  static const String programSystems = 'Ing. de Sistemas';
  static const String programIndustrialDesign = 'Diseño Industrial';
  static const String programBusiness = 'Administración';
  static const String programArchitecture = 'Arquitectura';
  static const String programPsychology = 'Psicología';

  static const List<String> academicPrograms = [
    programSystems,
    programIndustrialDesign,
    programBusiness,
    programArchitecture,
    programPsychology,
  ];
}

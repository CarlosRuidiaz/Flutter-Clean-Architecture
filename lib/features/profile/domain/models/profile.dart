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

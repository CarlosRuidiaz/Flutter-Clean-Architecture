
class Profile {
  Profile({
    this.id,
    required this.fullName,
    required this.academicProgram,
    required this.semester,
    required this.skills,
  });

  final String? id;
  final String fullName;
  final String academicProgram;
  final int semester;
  final List<String> skills;
  
  bool get isComplete =>
      fullName.isNotEmpty &&
      academicProgram.isNotEmpty &&
      semester > 0 &&
      skills.isNotEmpty;
}

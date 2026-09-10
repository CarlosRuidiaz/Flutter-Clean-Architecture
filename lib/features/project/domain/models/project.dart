enum ProjectStage { idea, teamFormation, research, prototype, testing, finished }

class Project {
  Project({
    this.id,
    required this.title,
    required this.stage,
    required this.academicProgram,
    required this.currentMembers,
    required this.maxMembers,
    required this.skillsWanted,
  });

  String? id;
  String title;
  ProjectStage stage;
  String academicProgram;
  int currentMembers;
  int maxMembers;
  List<String> skillsWanted;

  bool get isFull => currentMembers >= maxMembers;
}

class ProjectFeedback {
  ProjectFeedback({
    this.id,
    required this.projectId,
    required this.authorId,
    required this.authorName,
    required this.usability,
    required this.innovation,
    required this.visualDesign,
    required this.feasibility,
    this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String? id;
  final String projectId;
  final String authorId;
  final String authorName;
  final int usability;
  final int innovation;
  final int visualDesign;
  final int feasibility;
  final String? comment;
  final DateTime createdAt;

  factory ProjectFeedback.fromJson(Map<String, dynamic> json) {
    return ProjectFeedback(
      id: (json['_id'] ?? json['id'])?.toString(),
      projectId: json['project_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      usability: int.tryParse(json['usability']?.toString() ?? '1') ?? 1,
      innovation: int.tryParse(json['innovation']?.toString() ?? '1') ?? 1,
      visualDesign: int.tryParse(json['visual_design']?.toString() ?? '1') ?? 1,
      feasibility: int.tryParse(json['feasibility']?.toString() ?? '1') ?? 1,
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'project_id': projectId,
        'author_id': authorId,
        'author_name': authorName,
        'usability': usability,
        'innovation': innovation,
        'visual_design': visualDesign,
        'feasibility': feasibility,
        if (comment != null) 'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toJsonNoId() => {
        'project_id': projectId,
        'author_id': authorId,
        'author_name': authorName,
        'usability': usability,
        'innovation': innovation,
        'visual_design': visualDesign,
        'feasibility': feasibility,
        if (comment != null) 'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };

  ProjectFeedback copyWith({
    String? id,
    String? projectId,
    String? authorId,
    String? authorName,
    int? usability,
    int? innovation,
    int? visualDesign,
    int? feasibility,
    String? comment,
    DateTime? createdAt,
  }) {
    return ProjectFeedback(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      usability: usability ?? this.usability,
      innovation: innovation ?? this.innovation,
      visualDesign: visualDesign ?? this.visualDesign,
      feasibility: feasibility ?? this.feasibility,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

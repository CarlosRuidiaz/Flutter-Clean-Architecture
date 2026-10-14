class ProjectComment {
  ProjectComment({
    this.id,
    required this.projectId,
    required this.authorId,
    required this.authorName,
    required this.text,
    this.parentId,
    this.isTeam = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String? id;
  final String projectId;
  final String authorId;
  final String authorName;
  final String text;
  final String? parentId;
  final bool isTeam;
  final DateTime createdAt;

  bool get isReply => parentId != null && parentId!.isNotEmpty;

  factory ProjectComment.fromJson(Map<String, dynamic> json) {
    return ProjectComment(
      id: (json['_id'] ?? json['id'])?.toString(),
      projectId: json['project_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      isTeam: json['is_team'] == true ||
          json['is_team']?.toString().toLowerCase() == 'true',
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
        'text': text,
        if (parentId != null) 'parent_id': parentId,
        'is_team': isTeam,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toJsonNoId() => {
        'project_id': projectId,
        'author_id': authorId,
        'author_name': authorName,
        'text': text,
        if (parentId != null) 'parent_id': parentId,
        'is_team': isTeam,
        'created_at': createdAt.toIso8601String(),
      };

  ProjectComment copyWith({
    String? id,
    String? projectId,
    String? authorId,
    String? authorName,
    String? text,
    String? parentId,
    bool? isTeam,
    DateTime? createdAt,
  }) {
    return ProjectComment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      text: text ?? this.text,
      parentId: parentId ?? this.parentId,
      isTeam: isTeam ?? this.isTeam,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

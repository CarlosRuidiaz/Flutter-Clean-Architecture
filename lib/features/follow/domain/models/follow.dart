class Follow {
  Follow({
    this.id,
    required this.projectId,
    required this.userId,
    this.active = true,
  });

  final String? id;
  final String projectId;
  final String userId;
  final bool active;

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: (json['_id'] ?? json['id'])?.toString(),
      projectId: json['project_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      active: json['active'] == null
          ? true
          : (json['active'] is bool
              ? json['active'] as bool
              : json['active'].toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJsonNoId() => {
        'project_id': projectId,
        'user_id': userId,
        'active': active,
      };

  Follow copyWith({bool? active}) {
    return Follow(
      id: id,
      projectId: projectId,
      userId: userId,
      active: active ?? this.active,
    );
  }
}

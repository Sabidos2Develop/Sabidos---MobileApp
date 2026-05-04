class UserProgress {
  final int points;
  final List<String> achievements;

  UserProgress({required this.points, required this.achievements});

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      points: json["points"],
      achievements: List<String>.from(json["achievements"] ?? []),
    );
  }
}

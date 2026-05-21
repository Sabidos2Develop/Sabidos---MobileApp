class UserProgress {
  // final List<String> achievements;
  final int totalPoints;
  // final List<String> unlockedAchievements;

  UserProgress({
    // required this.achievements,
    required this.totalPoints,
    // required this.unlockedAchievements,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalPoints: json["totalPoints"],

      // achievements: List<String>.from(json["achievements"] ?? []),
    );
  }
}

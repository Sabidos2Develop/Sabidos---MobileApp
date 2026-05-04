class EarnResponse {
  final int earnedPoints;
  final int totalPoints;
  final List<String> unlockedAchievements;

  EarnResponse({
    required this.earnedPoints,
    required this.totalPoints,
    required this.unlockedAchievements,
  });

  factory EarnResponse.fromJson(Map<String, dynamic> json) {
    return EarnResponse(
      earnedPoints: json["earnedPoints"],
      totalPoints: json["totalPoints"],
      unlockedAchievements: List<String>.from(
        json["unlockedAchievements"] ?? [],
      ),
    );
  }
}

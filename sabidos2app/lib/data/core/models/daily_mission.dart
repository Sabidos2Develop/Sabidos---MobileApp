class DailyMission {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int goal;
  final int progress;
  final bool completed;
  final bool claimed;
  final int xpReward;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.goal,
    required this.progress,
    required this.completed,
    required this.claimed,
    required this.xpReward,
  });

  factory DailyMission.fromMap(Map<String, dynamic> map) {
    return DailyMission(
      id: map['id'] ?? map['Id'] ?? '',
      title: map['title'] ?? map['Title'] ?? '',
      description: map['description'] ?? map['Description'] ?? '',
      emoji: map['emoji'] ?? map['Emoji'] ?? '🎯',
      goal: map['goal'] ?? map['Goal'] ?? 1,
      progress: map['progress'] ?? map['Progress'] ?? 0,
      completed: map['completed'] ?? map['Completed'] ?? false,
      claimed: map['claimed'] ?? map['Claimed'] ?? false,
      xpReward: map['xpReward'] ?? map['XpReward'] ?? 0,
    );
  }

  double get progressValue => (progress / goal).clamp(0.0, 1.0);
}

class LevelInfo {
  final int level;
  final String title;
  final String emoji;
  final double floor;
  final double? nextFloor;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.emoji,
    required this.floor,
    required this.nextFloor,
  });

  double progress(double totalSaved) {
    if (nextFloor == null) return 1;
    final span = nextFloor! - floor;
    if (span <= 0) return 1;
    return ((totalSaved - floor) / span).clamp(0, 1);
  }
}

class LevelSystem {
  LevelSystem._();

  static const List<(double, String, String)> _tiers = [
    (0, '지름신 새내기', '🌱'),
    (100000, '짠테크 입문자', '🌿'),
    (300000, '절약 스킬러', '🍀'),
    (600000, '냉철한 소비요정', '🦉'),
    (1000000, '살까 마스터', '👑'),
  ];

  static LevelInfo forTotalSaved(double totalSaved) {
    var idx = 0;
    for (var i = 0; i < _tiers.length; i++) {
      if (totalSaved >= _tiers[i].$1) idx = i;
    }
    final (floor, title, emoji) = _tiers[idx];
    final nextFloor = idx + 1 < _tiers.length ? _tiers[idx + 1].$1 : null;
    return LevelInfo(
      level: idx + 1,
      title: title,
      emoji: emoji,
      floor: floor,
      nextFloor: nextFloor,
    );
  }
}

class BadgeStats {
  final int savedCount;
  final double totalSaved;
  final int streak;

  const BadgeStats({
    required this.savedCount,
    required this.totalSaved,
    required this.streak,
  });
}

class BadgeDef {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool Function(BadgeStats stats) isUnlocked;

  const BadgeDef({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });
}

final List<BadgeDef> allBadges = [
  BadgeDef(
    id: 'first_save',
    emoji: '🎉',
    title: '첫 승리',
    description: '처음으로 유혹을 참아냈어요',
    isUnlocked: (s) => s.savedCount >= 1,
  ),
  BadgeDef(
    id: 'streak_3',
    emoji: '🔥',
    title: '3연속 참기',
    description: '3번 연속으로 지름신을 물리쳤어요',
    isUnlocked: (s) => s.streak >= 3,
  ),
  BadgeDef(
    id: 'streak_7',
    emoji: '⚡',
    title: '7연속 참기',
    description: '일주일 내내 흔들리지 않았어요',
    isUnlocked: (s) => s.streak >= 7,
  ),
  BadgeDef(
    id: 'save_100k',
    emoji: '💰',
    title: '10만원 세이버',
    description: '누적 10만원을 아꼈어요',
    isUnlocked: (s) => s.totalSaved >= 100000,
  ),
  BadgeDef(
    id: 'save_500k',
    emoji: '💎',
    title: '50만원 세이버',
    description: '누적 50만원을 아꼈어요',
    isUnlocked: (s) => s.totalSaved >= 500000,
  ),
  BadgeDef(
    id: 'save_10x',
    emoji: '👑',
    title: '살까 마스터',
    description: '10번 이상 참아냈어요',
    isUnlocked: (s) => s.savedCount >= 10,
  ),
];

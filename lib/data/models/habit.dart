/// Habit domain model — the single source of truth for one habit.
///
/// Kept UI-free on purpose: screens render from this, nothing else.
library;

/// How often a habit is expected to happen.
enum HabitRhythm {
  everyDay('Every Day'),
  weekdays('Weekdays'),
  weekends('Weekends'),
  custom('Custom');

  const HabitRhythm(this.label);

  final String label;

  static HabitRhythm fromName(String? name) => HabitRhythm.values.firstWhere(
        (r) => r.name == name,
        orElse: () => HabitRhythm.everyDay,
      );
}

/// Accent tokens offered by the Add-habit palette.
enum HabitAccent {
  terracotta('terracotta'),
  sage('sage'),
  ochre('ochre'),
  slate('slate');

  const HabitAccent(this.key);

  final String key;

  static HabitAccent fromKey(String? key) => HabitAccent.values.firstWhere(
        (a) => a.key == key,
        orElse: () => HabitAccent.terracotta,
      );
}

/// A single habit the user is tracking.
///
/// `days` uses ISO weekdays (1 = Monday … 7 = Sunday) and only matters for
/// [HabitRhythm.custom] / weekdays / weekends.
class Habit {
  const Habit({
    required this.id,
    required this.title,
    this.note = '',
    this.iconKey = 'book',
    this.accent = HabitAccent.terracotta,
    this.rhythm = HabitRhythm.everyDay,
    this.days = const {1, 2, 3, 4, 5, 6, 7},
    this.targetAmount = 1,
    this.targetUnit = 'times',
    this.reminderTime,
    this.category = 'Daily Ritual',
    this.detailTag = '',
    this.sortOrder = 0,
    required this.createdAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String note;
  final String iconKey;
  final HabitAccent accent;
  final HabitRhythm rhythm;
  final Set<int> days;
  final int targetAmount;
  final String targetUnit;

  /// `HH:mm` local time, or null when the habit has no reminder.
  final String? reminderTime;

  /// Chip text shown next to the title (Daily Ritual / Morning / Evening …).
  final String category;

  /// Optional second meta chip, e.g. the book name on "Read 20 Pages".
  final String detailTag;

  final int sortOrder;
  final DateTime createdAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  /// Is this habit expected on [day]?
  bool isScheduledOn(DateTime day) {
    if (isArchived) return false;
    final weekday = day.weekday;
    return switch (rhythm) {
      HabitRhythm.everyDay => true,
      HabitRhythm.weekdays => weekday <= 5,
      HabitRhythm.weekends => weekday >= 6,
      HabitRhythm.custom => days.contains(weekday),
    };
  }

  Habit copyWith({
    String? title,
    String? note,
    String? iconKey,
    HabitAccent? accent,
    HabitRhythm? rhythm,
    Set<int>? days,
    int? targetAmount,
    String? targetUnit,
    String? reminderTime,
    bool clearReminder = false,
    String? category,
    String? detailTag,
    int? sortOrder,
    DateTime? archivedAt,
    bool clearArchived = false,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      iconKey: iconKey ?? this.iconKey,
      accent: accent ?? this.accent,
      rhythm: rhythm ?? this.rhythm,
      days: days ?? this.days,
      targetAmount: targetAmount ?? this.targetAmount,
      targetUnit: targetUnit ?? this.targetUnit,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      category: category ?? this.category,
      detailTag: detailTag ?? this.detailTag,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      archivedAt: clearArchived ? null : (archivedAt ?? this.archivedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'iconKey': iconKey,
        'accent': accent.key,
        'rhythm': rhythm.name,
        'days': days.toList()..sort(),
        'targetAmount': targetAmount,
        'targetUnit': targetUnit,
        'reminderTime': reminderTime,
        'category': category,
        'detailTag': detailTag,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
        'archivedAt': archivedAt?.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        note: json['note'] as String? ?? '',
        iconKey: json['iconKey'] as String? ?? 'book',
        accent: HabitAccent.fromKey(json['accent'] as String?),
        rhythm: HabitRhythm.fromName(json['rhythm'] as String?),
        days: ((json['days'] as List?) ?? const [1, 2, 3, 4, 5, 6, 7])
            .map((d) => (d as num).toInt())
            .toSet(),
        targetAmount: (json['targetAmount'] as num?)?.toInt() ?? 1,
        targetUnit: json['targetUnit'] as String? ?? 'times',
        reminderTime: json['reminderTime'] as String?,
        category: json['category'] as String? ?? 'Daily Ritual',
        detailTag: json['detailTag'] as String? ?? '',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        archivedAt: DateTime.tryParse(json['archivedAt'] as String? ?? ''),
      );

  @override
  bool operator ==(Object other) => other is Habit && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Habit($id, $title)';
}

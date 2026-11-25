import 'package:flutter/foundation.dart';

/// Represents a single house plant tracked in GreenLeaf.
@immutable
class Plant {
  const Plant({
    required this.id,
    required this.name,
    required this.emoji,
    required this.room,
    required this.waterEveryDays,
    required this.lastWatered,
    this.sunlight = 'Bright Indirect',
    this.careTip = 'Check the top inch of soil before watering.',
    this.wateredCount = 1,
  });

  final String id;
  final String name;
  final String emoji;
  final String room;
  final int waterEveryDays;
  final DateTime lastWatered;
  final String sunlight;
  final String careTip;
  final int wateredCount;

  factory Plant.fromMap(Map<String, dynamic> map) {
    final rawLastWatered = map['last_watered'];
    final parsedLastWatered = rawLastWatered is String
        ? DateTime.parse(rawLastWatered).toLocal()
        : DateTime.now();

    return Plant(
      id: map['id'].toString(),
      name: (map['name'] as String?) ?? 'Unnamed Plant',
      emoji: (map['emoji'] as String?) ?? '🌿',
      room: (map['room'] as String?) ?? 'Living Room',
      waterEveryDays: (map['water_every_days'] as num?)?.toInt() ?? 4,
      lastWatered: parsedLastWatered,
      sunlight: (map['sunlight'] as String?) ?? 'Bright Indirect',
      careTip: (map['care_tip'] as String?) ??
          'Check the top inch of soil before watering.',
      wateredCount: (map['watered_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'emoji': emoji,
      'room': room,
      'water_every_days': waterEveryDays,
      'last_watered': lastWatered.toUtc().toIso8601String(),
      'sunlight': sunlight,
      'care_tip': careTip,
      'watered_count': wateredCount,
    };
  }

  DateTime get _todayDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _lastWateredDate =>
      DateTime(lastWatered.year, lastWatered.month, lastWatered.day);

  /// The next calendar date this plant needs watering.
  DateTime get nextWateringDate =>
      _lastWateredDate.add(Duration(days: waterEveryDays));

  /// Number of days until the next watering (0 = today, negative = overdue).
  int get daysUntilNextWatering =>
      nextWateringDate.difference(_todayDate).inDays;

  /// True if the plant needs watering today or is overdue.
  bool get isDueToday => daysUntilNextWatering <= 0;

  /// True if the plant was watered today.
  bool get wasWateredToday => _lastWateredDate == _todayDate;

  /// Human-readable watering interval label.
  String get scheduleLabel =>
      waterEveryDays == 1 ? 'Water every day' : 'Water every $waterEveryDays days';

  /// Friendly status text for badges and cards.
  String get statusLabel {
    if (wasWateredToday) {
      return 'Watered today';
    }
    final remaining = daysUntilNextWatering;
    if (remaining < 0) {
      final overdue = remaining.abs();
      return overdue == 1 ? 'Overdue by 1 day' : 'Overdue by $overdue days';
    }
    if (remaining == 0) {
      return 'Water today';
    }
    if (remaining == 1) {
      return 'In 1 day';
    }
    return 'In $remaining days';
  }

  Plant copyWith({
    String? id,
    String? name,
    String? emoji,
    String? room,
    int? waterEveryDays,
    DateTime? lastWatered,
    String? sunlight,
    String? careTip,
    int? wateredCount,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      room: room ?? this.room,
      waterEveryDays: waterEveryDays ?? this.waterEveryDays,
      lastWatered: lastWatered ?? this.lastWatered,
      sunlight: sunlight ?? this.sunlight,
      careTip: careTip ?? this.careTip,
      wateredCount: wateredCount ?? this.wateredCount,
    );
  }
}

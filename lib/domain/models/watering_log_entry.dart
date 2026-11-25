import 'package:flutter/foundation.dart';

/// Represents a row in the Supabase `watering_log` table.
@immutable
class WateringLogEntry {
  const WateringLogEntry({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.wateredAt,
    this.note,
  });

  final String id;
  final String plantId;
  final String plantName;
  final DateTime wateredAt;
  final String? note;

  factory WateringLogEntry.fromMap(Map<String, dynamic> map) {
    final rawDate = map['watered_at'];
    return WateringLogEntry(
      id: map['id'].toString(),
      plantId: map['plant_id'].toString(),
      plantName: (map['plant_name'] as String?) ?? '',
      wateredAt: rawDate is String
          ? DateTime.parse(rawDate).toLocal()
          : DateTime.now(),
      note: map['note'] as String?,
    );
  }
}

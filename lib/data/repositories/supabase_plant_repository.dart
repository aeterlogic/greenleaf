import 'package:greenleaf/data/repositories/plant_repository.dart';
import 'package:greenleaf/domain/models/plant.dart';
import 'package:greenleaf/domain/models/watering_log_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation using the `plants` and `watering_log` tables.
class SupabasePlantRepository implements PlantRepository {
  SupabasePlantRepository({required this.client});

  final SupabaseClient client;

  @override
  Future<List<Plant>> fetchPlants() async {
    final response = await client
        .from('plants')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => Plant.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Plant> addPlant({
    required String name,
    required String emoji,
    required String room,
    required int waterEveryDays,
    required String sunlight,
    required String careTip,
    required bool dueToday,
  }) async {
    final now = DateTime.now();
    final lastWatered =
        dueToday ? now.subtract(Duration(days: waterEveryDays)) : now;

    final payload = {
      'name': name.trim(),
      'emoji': emoji,
      'room': room.trim(),
      'water_every_days': waterEveryDays,
      'last_watered': lastWatered.toUtc().toIso8601String(),
      'sunlight': sunlight,
      'care_tip': careTip.trim().isEmpty
          ? 'Check the top inch of soil before watering.'
          : careTip.trim(),
      'watered_count': dueToday ? 0 : 1,
    };

    final inserted =
        await client.from('plants').insert(payload).select().single();

    return Plant.fromMap(inserted);
  }

  @override
  Future<Plant> waterPlant(Plant plant, {String? note}) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    // 1. Insert a row into `watering_log`
    await client.from('watering_log').insert({
      'plant_id': plant.id,
      'plant_name': plant.name,
      'watered_at': nowIso,
      'note': note ?? 'Watered via GreenLeaf',
    });

    // 2. Update `last_watered` and `watered_count` on `plants`
    final updatedRow = await client
        .from('plants')
        .update({
          'last_watered': nowIso,
          'watered_count': plant.wateredCount + 1,
        })
        .eq('id', plant.id)
        .select()
        .single();

    return Plant.fromMap(updatedRow);
  }

  @override
  Future<List<WateringLogEntry>> fetchWateringLog(String plantId) async {
    final response = await client
        .from('watering_log')
        .select()
        .eq('plant_id', plantId)
        .order('watered_at', ascending: false)
        .limit(10);

    return (response as List<dynamic>)
        .map((row) => WateringLogEntry.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deletePlant(String id) async {
    await client.from('plants').delete().eq('id', id);
  }
}

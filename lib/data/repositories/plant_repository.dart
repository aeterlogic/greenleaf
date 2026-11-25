import 'package:greenleaf/domain/models/plant.dart';
import 'package:greenleaf/domain/models/watering_log_entry.dart';

/// Contract for loading, creating, watering, and deleting plants.
abstract class PlantRepository {
  Future<List<Plant>> fetchPlants();

  Future<Plant> addPlant({
    required String name,
    required String emoji,
    required String room,
    required int waterEveryDays,
    required String sunlight,
    required String careTip,
    required bool dueToday,
  });

  Future<Plant> waterPlant(Plant plant, {String? note});

  Future<List<WateringLogEntry>> fetchWateringLog(String plantId);

  Future<void> deletePlant(String id);
}

/// In-memory implementation seeded with the 8 sample plants (used for tests).
class InMemoryPlantRepository implements PlantRepository {
  InMemoryPlantRepository() : _plants = _seedPlants();

  final List<Plant> _plants;
  final List<WateringLogEntry> _logs = [];

  static List<Plant> _seedPlants() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Plant(
        id: 'plant-1',
        name: 'Money Plant',
        emoji: '🌿',
        room: 'Living Room',
        waterEveryDays: 4,
        lastWatered: today.subtract(const Duration(days: 4)),
        sunlight: 'Bright Indirect',
        careTip:
            'Loves indirect light and slightly dry topsoil between waterings. Wipe leaves gently for a healthy shine.',
        wateredCount: 6,
      ),
      Plant(
        id: 'plant-2',
        name: 'Aloe Vera',
        emoji: '🪴',
        room: 'Bedroom',
        waterEveryDays: 10,
        lastWatered: today.subtract(const Duration(days: 4)),
        sunlight: 'Bright Sun',
        careTip:
            'Soak deeply, then allow the soil to dry completely before watering again. Avoid soggy roots.',
        wateredCount: 4,
      ),
      Plant(
        id: 'plant-3',
        name: 'Snake Plant',
        emoji: '🌱',
        room: 'Study',
        waterEveryDays: 14,
        lastWatered: today.subtract(const Duration(days: 6)),
        sunlight: 'Low to Bright Light',
        careTip:
            'Super resilient and purifies indoor air. Water sparingly around the rim rather than the leaf center.',
        wateredCount: 3,
      ),
      Plant(
        id: 'plant-4',
        name: 'Tulsi',
        emoji: '☘️',
        room: 'Balcony',
        waterEveryDays: 2,
        lastWatered: today.subtract(const Duration(days: 2)),
        sunlight: 'Direct Sun',
        careTip:
            'Thrives in warm morning sunlight. Keep soil evenly moist and pinch flower buds for bushier leaves.',
        wateredCount: 12,
      ),
      Plant(
        id: 'plant-5',
        name: 'Rose',
        emoji: '🌹',
        room: 'Terrace',
        waterEveryDays: 3,
        lastWatered: today.subtract(const Duration(days: 3)),
        sunlight: 'Direct Sun',
        careTip:
            'Water at the base early in the morning to keep petals dry and prevent leaf spots.',
        wateredCount: 8,
      ),
      Plant(
        id: 'plant-6',
        name: 'Mint',
        emoji: '🍃',
        room: 'Kitchen',
        waterEveryDays: 2,
        lastWatered: today.subtract(const Duration(days: 1)),
        sunlight: 'Partial Sun',
        careTip:
            'Prefers consistently cool, lightly damp soil. Snip top sprigs regularly to encourage fresh growth.',
        wateredCount: 9,
      ),
      Plant(
        id: 'plant-7',
        name: 'Peace Lily',
        emoji: '🌸',
        room: 'Living Room',
        waterEveryDays: 5,
        lastWatered: today.subtract(const Duration(days: 5)),
        sunlight: 'Low to Medium Light',
        careTip:
            'Drooping leaves are a polite reminder for water. Loves occasional misting for tropical humidity.',
        wateredCount: 5,
      ),
      Plant(
        id: 'plant-8',
        name: 'Cactus',
        emoji: '🌵',
        room: 'Work Desk',
        waterEveryDays: 14,
        lastWatered: today.subtract(const Duration(days: 5)),
        sunlight: 'Direct Sun',
        careTip:
            'Needs plenty of sunshine and fast-draining soil. Less water is always safer than too much.',
        wateredCount: 2,
      ),
    ];
  }

  @override
  Future<List<Plant>> fetchPlants() async => List<Plant>.of(_plants);

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
    final today = DateTime(now.year, now.month, now.day);
    final lastWatered =
        dueToday ? today.subtract(Duration(days: waterEveryDays)) : now;

    final plant = Plant(
      id: 'plant-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      emoji: emoji,
      room: room.trim(),
      waterEveryDays: waterEveryDays,
      lastWatered: lastWatered,
      sunlight: sunlight,
      careTip: careTip.trim().isEmpty
          ? 'Check the top inch of soil before watering.'
          : careTip.trim(),
      wateredCount: dueToday ? 0 : 1,
    );
    _plants.insert(0, plant);
    return plant;
  }

  @override
  Future<Plant> waterPlant(Plant plant, {String? note}) async {
    final now = DateTime.now();
    final index = _plants.indexWhere((p) => p.id == plant.id);
    final updated = plant.copyWith(
      lastWatered: now,
      wateredCount: plant.wateredCount + 1,
    );
    if (index != -1) {
      _plants[index] = updated;
    }
    _logs.insert(
      0,
      WateringLogEntry(
        id: 'log-${now.microsecondsSinceEpoch}',
        plantId: plant.id,
        plantName: plant.name,
        wateredAt: now,
        note: note ?? 'Watered via GreenLeaf',
      ),
    );
    return updated;
  }

  @override
  Future<List<WateringLogEntry>> fetchWateringLog(String plantId) async {
    return _logs.where((log) => log.plantId == plantId).toList();
  }

  @override
  Future<void> deletePlant(String id) async {
    _plants.removeWhere((p) => p.id == id);
    _logs.removeWhere((log) => log.plantId == id);
  }
}

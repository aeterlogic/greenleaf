import 'package:flutter/foundation.dart';
import 'package:greenleaf/data/repositories/plant_repository.dart';
import 'package:greenleaf/domain/models/plant.dart';
import 'package:greenleaf/domain/models/watering_log_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages the list of plants, Supabase sync state, and cheerful watering messages.
class PlantsViewModel extends ChangeNotifier {
  PlantsViewModel({required this.repository});

  final PlantRepository repository;

  static const List<String> _happyMessages = [
    'is refreshed and glowing! ✨',
    'says thank you for the drink! 💚',
    'is happy and hydrated! 🌞',
    'is soaking up the love! 💧',
    'is thriving under your care! 🌿',
  ];

  int _messageIndex = 0;
  List<Plant> _plants = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  final Set<String> _wateringIds = {};

  List<Plant> get allPlants => List.unmodifiable(_plants);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  bool isWatering(String plantId) => _wateringIds.contains(plantId);

  List<Plant> get dueTodayPlants =>
      _plants.where((plant) => plant.isDueToday).toList();

  List<Plant> get wateredTodayPlants =>
      _plants.where((plant) => plant.wasWateredToday).toList();

  List<String> get rooms {
    final uniqueRooms = <String>{};
    for (final plant in _plants) {
      uniqueRooms.add(plant.room);
    }
    final sorted = uniqueRooms.toList()..sort();
    return ['All', ...sorted];
  }

  Plant? findById(String id) {
    for (final plant in _plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  String _friendlyError(Object error) {
    if (error is PostgrestException) {
      if (error.code == 'PGRST205' ||
          error.message.contains('Could not find the table')) {
        return 'Tables not found in Supabase yet. Run supabase/schema.sql in your Supabase SQL Editor, then tap Retry.';
      }
      return 'Supabase error: ${error.message}';
    }
    return 'Could not connect to Supabase. Check your connection and try again.';
  }

  /// Loads all plants from Supabase.
  Future<void> loadPlants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plants = List<Plant>.of(await repository.fetchPlants());
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves a row in `watering_log`, updates `plants`, and returns a cheerful message.
  Future<String> markPlantWatered(String plantId) async {
    final existing = findById(plantId);
    if (existing == null) {
      return 'Plant watered! 💧';
    }

    _wateringIds.add(plantId);
    notifyListeners();

    try {
      final updated = await repository.waterPlant(existing);
      final index = _plants.indexWhere((p) => p.id == plantId);
      if (index != -1) {
        _plants[index] = updated;
      }
      final suffix = _happyMessages[_messageIndex % _happyMessages.length];
      _messageIndex++;
      return 'Yay! ${updated.emoji} ${updated.name} $suffix';
    } finally {
      _wateringIds.remove(plantId);
      notifyListeners();
    }
  }

  /// Saves a new plant to Supabase `plants` table.
  Future<Plant> addPlant({
    required String name,
    required String emoji,
    required String room,
    required int waterEveryDays,
    required String sunlight,
    required String careTip,
    required bool dueToday,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final saved = await repository.addPlant(
        name: name,
        emoji: emoji,
        room: room,
        waterEveryDays: waterEveryDays,
        sunlight: sunlight,
        careTip: careTip,
        dueToday: dueToday,
      );
      _plants = [saved, ..._plants];
      _errorMessage = null;
      return saved;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Fetches recent watering history for a plant from `watering_log`.
  Future<List<WateringLogEntry>> fetchWateringLog(String plantId) {
    return repository.fetchWateringLog(plantId);
  }

  /// Deletes a plant from Supabase.
  Future<void> deletePlant(String plantId) async {
    await repository.deletePlant(plantId);
    _plants = _plants.where((p) => p.id != plantId).toList();
    notifyListeners();
  }
}

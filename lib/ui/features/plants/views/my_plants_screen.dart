import 'package:material_ui/material_ui.dart';
import 'package:greenleaf/domain/models/plant.dart';
import 'package:greenleaf/ui/core/theme/app_theme.dart';
import 'package:greenleaf/ui/core/widgets/happy_message_toast.dart';
import 'package:greenleaf/ui/features/plants/view_models/plants_view_model.dart';
import 'package:greenleaf/ui/features/plants/views/plant_details_screen.dart';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({
    super.key,
    required this.viewModel,
  });

  final PlantsViewModel viewModel;

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoom = 'All';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(BuildContext context, Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantDetailsScreen(
          plantId: plant.id,
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  Future<void> _handleWatered(BuildContext context, Plant plant) async {
    try {
      final msg = await widget.viewModel.markPlantWatered(plant.id);
      if (!context.mounted) return;
      showHappyWateredMessage(context, msg);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFC62828),
          content: Text('Could not save watering to Supabase. Please retry.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final rooms = widget.viewModel.rooms;
        if (!rooms.contains(_selectedRoom)) {
          _selectedRoom = 'All';
        }

        final allPlants = widget.viewModel.allPlants;
        final filtered = allPlants.where((plant) {
          final matchesRoom =
              _selectedRoom == 'All' || plant.room == _selectedRoom;
          final q = _query.trim().toLowerCase();
          final matchesQuery = q.isEmpty ||
              plant.name.toLowerCase().contains(q) ||
              plant.room.toLowerCase().contains(q);
          return matchesRoom && matchesQuery;
        }).toList();

        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      'My Plants',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: GreenLeafColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: GreenLeafColors.softYellow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${allPlants.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: GreenLeafColors.yellowAccentText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.viewModel.isLoading
                          ? null
                          : widget.viewModel.loadPlants,
                      tooltip: 'Refresh from Supabase',
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: GreenLeafColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search plants or rooms...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: GreenLeafColors.primaryGreen,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Room filter chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: rooms.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final isSelected = room == _selectedRoom;
                    return ChoiceChip(
                      label: Text(room),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _selectedRoom = room),
                      backgroundColor: GreenLeafColors.pureWhite,
                      selectedColor: GreenLeafColors.primaryGreen,
                      side: BorderSide(
                        color: isSelected
                            ? GreenLeafColors.primaryGreen
                            : GreenLeafColors.softGreenBorder,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? GreenLeafColors.pureWhite
                            : GreenLeafColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Plant list
              Expanded(
                child: widget.viewModel.isLoading && allPlants.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: GreenLeafColors.primaryGreen,
                        ),
                      )
                    : RefreshIndicator(
                        color: GreenLeafColors.primaryGreen,
                        onRefresh: widget.viewModel.loadPlants,
                        child: filtered.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(36),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '🪴',
                                          style: TextStyle(fontSize: 42),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          widget.viewModel.errorMessage != null
                                              ? 'Waiting for Supabase tables'
                                              : 'No plants match your filter',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: GreenLeafColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.viewModel.errorMessage ??
                                              'Try a different room or search term.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: GreenLeafColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 24),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final plant = filtered[index];
                                  return _PlantListCard(
                                    plant: plant,
                                    isWatering:
                                        widget.viewModel.isWatering(plant.id),
                                    onTap: () => _openDetails(context, plant),
                                    onWatered: () =>
                                        _handleWatered(context, plant),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlantListCard extends StatelessWidget {
  const _PlantListCard({
    required this.plant,
    required this.isWatering,
    required this.onTap,
    required this.onWatered,
  });

  final Plant plant;
  final bool isWatering;
  final VoidCallback onTap;
  final VoidCallback onWatered;

  @override
  Widget build(BuildContext context) {
    final isDue = plant.isDueToday;

    return Material(
      color: GreenLeafColors.pureWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDue
                  ? GreenLeafColors.warmYellow
                  : GreenLeafColors.softGreenBorder,
              width: isDue ? 1.4 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x091B3524),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isDue
                      ? GreenLeafColors.softYellow
                      : GreenLeafColors.mintTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 27),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: GreenLeafColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${plant.room} • ${plant.scheduleLabel}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: GreenLeafColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDue
                            ? GreenLeafColors.softYellowTint
                            : GreenLeafColors.mintTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        plant.statusLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDue
                              ? GreenLeafColors.yellowAccentText
                              : GreenLeafColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isDue)
                ElevatedButton(
                  onPressed: isWatering ? null : onWatered,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GreenLeafColors.primaryGreen,
                    foregroundColor: GreenLeafColors.pureWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: isWatering
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GreenLeafColors.pureWhite,
                          ),
                        )
                      : const Text('Watered'),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: GreenLeafColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

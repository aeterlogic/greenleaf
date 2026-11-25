import 'package:material_ui/material_ui.dart';
import 'package:greenleaf/domain/models/plant.dart';
import 'package:greenleaf/ui/core/theme/app_theme.dart';
import 'package:greenleaf/ui/core/widgets/happy_message_toast.dart';
import 'package:greenleaf/ui/features/plants/view_models/plants_view_model.dart';
import 'package:greenleaf/ui/features/plants/views/plant_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.onGoToAddPlant,
  });

  final PlantsViewModel viewModel;
  final VoidCallback onGoToAddPlant;

  String _formattedToday() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _openDetails(BuildContext context, Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantDetailsScreen(
          plantId: plant.id,
          viewModel: viewModel,
        ),
      ),
    );
  }

  Future<void> _handleWatered(BuildContext context, Plant plant) async {
    try {
      final happyMsg = await viewModel.markPlantWatered(plant.id);
      if (!context.mounted) return;
      showHappyWateredMessage(context, happyMsg);
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
      listenable: viewModel,
      builder: (context, _) {
        final duePlants = viewModel.dueTodayPlants;
        final wateredToday = viewModel.wateredTodayPlants;
        final totalTodayTasks = duePlants.length + wateredToday.length;
        final progress = totalTodayTasks == 0
            ? 1.0
            : wateredToday.length / totalTodayTasks;

        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: GreenLeafColors.primaryGreen,
            onRefresh: viewModel.loadPlants,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand row
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: GreenLeafColors.primaryGreen,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Center(
                                child: Text('🌿', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'greenleaf',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: GreenLeafColors.textPrimary,
                                    letterSpacing: -0.5,
                                    height: 1.05,
                                  ),
                                ),
                                Text(
                                  'Daily Plant Care',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: GreenLeafColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: GreenLeafColors.softYellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 14,
                                    color: GreenLeafColors.yellowAccentText,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formattedToday(),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: GreenLeafColors.yellowAccentText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed:
                                  viewModel.isLoading ? null : viewModel.loadPlants,
                              tooltip: 'Refresh from Supabase',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                size: 20,
                                color: GreenLeafColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Hero Daily Watering Summary Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                GreenLeafColors.primaryGreen,
                                GreenLeafColors.freshGreen,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x242E7D32),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          duePlants.isEmpty
                                              ? 'All plants are happy! 🌞'
                                              : duePlants.length == 1
                                                  ? '1 plant needs water today'
                                                  : '${duePlants.length} plants need water today',
                                          style: const TextStyle(
                                            color: GreenLeafColors.pureWhite,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          duePlants.isEmpty
                                              ? 'Synced with Supabase • keep growing!'
                                              : 'Tap "Watered" once you give them a drink.',
                                          style: const TextStyle(
                                            color: Color(0xFFE6F4E8),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: GreenLeafColors.softYellow,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        duePlants.isEmpty ? '✨' : '💧',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: const Color(0x3DFFFFFF),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    GreenLeafColors.softYellow,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${wateredToday.length} of $totalTodayTasks watered today',
                                    style: const TextStyle(
                                      color: GreenLeafColors.softYellow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${viewModel.allPlants.length} total plants',
                                    style: const TextStyle(
                                      color: Color(0xFFDDF2DF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (viewModel.isLoading && viewModel.allPlants.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: GreenLeafColors.primaryGreen,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Loading plants from Supabase...',
                            style: TextStyle(
                              color: GreenLeafColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (viewModel.errorMessage != null &&
                    viewModel.allPlants.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: GreenLeafColors.softYellowTint,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: GreenLeafColors.warmYellow,
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('🪴', style: TextStyle(fontSize: 38)),
                            const SizedBox(height: 10),
                            const Text(
                              'Finish Supabase Table Setup',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: GreenLeafColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: GreenLeafColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: viewModel.loadPlants,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Section: Today's Plants to Water
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Watering",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: GreenLeafColors.textPrimary,
                            ),
                          ),
                          if (duePlants.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: GreenLeafColors.softYellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${duePlants.length} due',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: GreenLeafColors.yellowAccentText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (duePlants.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: GreenLeafColors.softYellowTint,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: GreenLeafColors.warmYellow,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('🌻', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 10),
                              const Text(
                                'All watered for today!',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: GreenLeafColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Every thirsty plant has been taken care of. Enjoy your lush green space!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: GreenLeafColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: onGoToAddPlant,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: GreenLeafColors.primaryGreen,
                                  side: const BorderSide(
                                    color: GreenLeafColors.primaryGreen,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text(
                                  'Add Another Plant',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.separated(
                        itemCount: duePlants.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final plant = duePlants[index];
                          return _TodayPlantCard(
                            plant: plant,
                            isWatering: viewModel.isWatering(plant.id),
                            onTap: () => _openDetails(context, plant),
                            onWatered: () => _handleWatered(context, plant),
                          );
                        },
                      ),
                    ),

                  // Section: Watered Today
                  if (wateredToday.isNotEmpty) ...[
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Watered Today',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: GreenLeafColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList.separated(
                        itemCount: wateredToday.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final plant = wateredToday[index];
                          return _CompletedPlantTile(
                            plant: plant,
                            onTap: () => _openDetails(context, plant),
                          );
                        },
                      ),
                    ),
                  ] else
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TodayPlantCard extends StatelessWidget {
  const _TodayPlantCard({
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
              color: GreenLeafColors.softGreenBorder,
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B1B3524),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: GreenLeafColors.softYellow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 28),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: GreenLeafColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.room_outlined,
                          size: 13,
                          color: GreenLeafColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            plant.room,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: GreenLeafColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.scheduleLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GreenLeafColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isWatering ? null : onWatered,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GreenLeafColors.primaryGreen,
                  foregroundColor: GreenLeafColors.pureWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  minimumSize: const Size(0, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: isWatering
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: GreenLeafColors.pureWhite,
                        ),
                      )
                    : const Icon(Icons.water_drop_rounded, size: 15),
                label: const Text('Watered'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedPlantTile extends StatelessWidget {
  const _CompletedPlantTile({
    required this.plant,
    required this.onTap,
  });

  final Plant plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GreenLeafColors.mintTint,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GreenLeafColors.pureWhite,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 22),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: GreenLeafColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${plant.room} • ${plant.scheduleLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: GreenLeafColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: GreenLeafColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: GreenLeafColors.primaryGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: GreenLeafColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

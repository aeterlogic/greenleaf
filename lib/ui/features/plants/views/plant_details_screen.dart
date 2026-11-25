import 'package:material_ui/material_ui.dart';
import 'package:greenleaf/domain/models/watering_log_entry.dart';
import 'package:greenleaf/ui/core/theme/app_theme.dart';
import 'package:greenleaf/ui/core/widgets/happy_message_toast.dart';
import 'package:greenleaf/ui/features/plants/view_models/plants_view_model.dart';

class PlantDetailsScreen extends StatefulWidget {
  const PlantDetailsScreen({
    super.key,
    required this.plantId,
    required this.viewModel,
  });

  final String plantId;
  final PlantsViewModel viewModel;

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  List<WateringLogEntry> _logs = [];
  bool _loadingLogs = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final entries = await widget.viewModel.fetchWateringLog(widget.plantId);
      if (!mounted) return;
      setState(() {
        _logs = entries;
        _loadingLogs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLogs = false);
    }
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${_formatDate(date)} • $hour:$minute $period';
  }

  Future<void> _handleWatered() async {
    try {
      final happyMsg = await widget.viewModel.markPlantWatered(widget.plantId);
      if (!mounted) return;
      showHappyWateredMessage(context, happyMsg);
      await _loadLogs();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFC62828),
          content: Text('Could not log watering in Supabase. Please retry.'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, String plantName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GreenLeafColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Remove Plant?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: GreenLeafColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove $plantName from GreenLeaf?',
          style: const TextStyle(color: GreenLeafColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: GreenLeafColors.pureWhite,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await widget.viewModel.deletePlant(widget.plantId);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final plant = widget.viewModel.findById(widget.plantId);
        if (plant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Plant Details')),
            body: const Center(child: Text('Plant not found.')),
          );
        }

        final isDue = plant.isDueToday;
        final isWatering = widget.viewModel.isWatering(plant.id);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              tooltip: 'Back',
            ),
            title: const Text('Plant Details'),
            actions: [
              IconButton(
                onPressed: () => _confirmDelete(context, plant.name),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: GreenLeafColors.textSecondary,
                ),
                tooltip: 'Remove plant',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        GreenLeafColors.softYellowTint,
                        GreenLeafColors.mintTint,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: GreenLeafColors.softGreenBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          color: GreenLeafColors.pureWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: GreenLeafColors.warmYellow,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x182E7D32),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            plant.emoji,
                            style: const TextStyle(fontSize: 54),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        plant.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: GreenLeafColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _BadgeChip(
                            icon: Icons.room_outlined,
                            label: plant.room,
                            backgroundColor: GreenLeafColors.pureWhite,
                            foregroundColor: GreenLeafColors.textPrimary,
                          ),
                          _BadgeChip(
                            icon: Icons.water_drop_outlined,
                            label: plant.scheduleLabel,
                            backgroundColor: GreenLeafColors.pureWhite,
                            foregroundColor: GreenLeafColors.primaryGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDue
                              ? GreenLeafColors.softYellow
                              : GreenLeafColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isDue
                              ? '💧 ${plant.statusLabel} — ready for a drink'
                              : '✨ ${plant.statusLabel} • Happy & hydrated',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDue
                                ? GreenLeafColors.yellowAccentText
                                : GreenLeafColors.pureWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Big Watered CTA button
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: isWatering ? null : _handleWatered,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GreenLeafColors.primaryGreen,
                      foregroundColor: GreenLeafColors.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: isWatering
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: GreenLeafColors.pureWhite,
                            ),
                          )
                        : Icon(
                            plant.wasWateredToday
                                ? Icons.check_circle_rounded
                                : Icons.water_drop_rounded,
                            size: 22,
                          ),
                    label: Text(
                      plant.wasWateredToday
                          ? 'Watered Today! Tap to Water Again'
                          : 'Watered',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Care stats 2x2 grid
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.schedule_rounded,
                        title: 'Frequency',
                        value: 'Every ${plant.waterEveryDays}d',
                        tint: GreenLeafColors.mintTint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.wb_sunny_outlined,
                        title: 'Sunlight',
                        value: plant.sunlight,
                        tint: GreenLeafColors.softYellowTint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.calendar_today_rounded,
                        title: 'Last Watered',
                        value: _formatDate(plant.lastWatered),
                        tint: GreenLeafColors.softYellowTint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.favorite_outline_rounded,
                        title: 'Care Streak',
                        value: '${plant.wateredCount} times',
                        tint: GreenLeafColors.mintTint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Care Tip card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GreenLeafColors.softYellowTint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: GreenLeafColors.warmYellow,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: GreenLeafColors.softYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tips_and_updates_rounded,
                          color: GreenLeafColors.yellowAccentText,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Care Tip',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: GreenLeafColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plant.careTip,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: GreenLeafColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Recent Watering Log from Supabase
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GreenLeafColors.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GreenLeafColors.softGreenBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 18,
                            color: GreenLeafColors.primaryGreen,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Watering Log',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: GreenLeafColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_loadingLogs)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: GreenLeafColors.primaryGreen,
                              ),
                            ),
                          ),
                        )
                      else if (_logs.isEmpty)
                        const Text(
                          'No watering entries logged yet. Tap "Watered" above to record one!',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: GreenLeafColors.textSecondary,
                          ),
                        )
                      else
                        Column(
                          children: _logs.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.water_drop_rounded,
                                    size: 15,
                                    color: GreenLeafColors.freshGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatDateTime(entry.wateredAt),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: GreenLeafColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GreenLeafColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GreenLeafColors.softGreenBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: GreenLeafColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: GreenLeafColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: GreenLeafColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:greenleaf/ui/core/theme/app_theme.dart';
import 'package:greenleaf/ui/core/widgets/happy_message_toast.dart';
import 'package:greenleaf/ui/features/plants/view_models/plants_view_model.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({
    super.key,
    required this.viewModel,
    required this.onPlantAdded,
  });

  final PlantsViewModel viewModel;
  final void Function({required bool dueToday}) onPlantAdded;

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController(text: 'Living Room');
  final _careTipController = TextEditingController();

  static const List<String> _emojis = [
    '🌿',
    '🪴',
    '🌱',
    '☘️',
    '🌹',
    '🍃',
    '🌸',
    '🌵',
    '🌺',
    '🌻',
    '🌷',
    '🌴',
  ];

  static const List<String> _roomSuggestions = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Balcony',
    'Study',
    'Terrace',
    'Work Desk',
  ];

  static const List<int> _dayPresets = [1, 2, 3, 4, 5, 7, 10, 14];

  static const List<String> _sunlightOptions = [
    'Direct Sun',
    'Bright Indirect',
    'Partial Sun',
    'Low Light',
  ];

  String _selectedEmoji = '🌿';
  int _waterEveryDays = 4;
  String _selectedSunlight = 'Bright Indirect';
  bool _needsWaterToday = true;

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _careTipController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final wasDueToday = _needsWaterToday;

    try {
      final plant = await widget.viewModel.addPlant(
        name: _nameController.text,
        emoji: _selectedEmoji,
        room: _roomController.text,
        waterEveryDays: _waterEveryDays,
        sunlight: _selectedSunlight,
        careTip: _careTipController.text,
        dueToday: wasDueToday,
      );

      if (!mounted) return;

      // Reset form for next addition
      _nameController.clear();
      _careTipController.clear();
      setState(() {
        _selectedEmoji = '🌿';
        _roomController.text = 'Living Room';
        _waterEveryDays = 4;
        _selectedSunlight = 'Bright Indirect';
        _needsWaterToday = true;
      });

      showHappyWateredMessage(
        context,
        'Welcome ${plant.emoji} ${plant.name} to your GreenLeaf garden! 🌱',
      );
      widget.onPlantAdded(dueToday: wasDueToday);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFC62828),
          content: Text(
            'Could not save plant to Supabase. Make sure tables are created.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final isSaving = widget.viewModel.isSaving;

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Plant',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: GreenLeafColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add a new green friend and save it to Supabase.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: GreenLeafColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Emoji Picker
                  const _SectionLabel('Choose a Plant Emoji'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GreenLeafColors.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: GreenLeafColors.softGreenBorder),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _emojis.map((emoji) {
                        final isSelected = emoji == _selectedEmoji;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? GreenLeafColors.softYellow
                                  : GreenLeafColors.appBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? GreenLeafColors.primaryGreen
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Plant Name
                  const _SectionLabel('Plant Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Monstera, Lavender, Jade Plant',
                      prefixIcon: Icon(
                        Icons.eco_outlined,
                        color: GreenLeafColors.primaryGreen,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a plant name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Room
                  const _SectionLabel('Room'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _roomController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Living Room, Balcony',
                      prefixIcon: Icon(
                        Icons.room_outlined,
                        color: GreenLeafColors.primaryGreen,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a room name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _roomSuggestions.map((room) {
                      final isSelected = _roomController.text.trim() == room;
                      return ActionChip(
                        label: Text(room),
                        backgroundColor: isSelected
                            ? GreenLeafColors.softYellow
                            : GreenLeafColors.pureWhite,
                        side: BorderSide(
                          color: isSelected
                              ? GreenLeafColors.warmYellow
                              : GreenLeafColors.softGreenBorder,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? GreenLeafColors.yellowAccentText
                              : GreenLeafColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _roomController.text = room;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Watering Frequency
                  const _SectionLabel('Watering Schedule'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GreenLeafColors.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: GreenLeafColors.softGreenBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton.filledTonal(
                              onPressed: _waterEveryDays > 1
                                  ? () => setState(() => _waterEveryDays--)
                                  : null,
                              style: IconButton.styleFrom(
                                backgroundColor: GreenLeafColors.mintTint,
                                foregroundColor: GreenLeafColors.primaryGreen,
                              ),
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            Column(
                              children: [
                                Text(
                                  _waterEveryDays == 1
                                      ? 'Water every day'
                                      : 'Water every $_waterEveryDays days',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: GreenLeafColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Tap + / - or pick a quick preset',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: GreenLeafColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            IconButton.filledTonal(
                              onPressed: _waterEveryDays < 60
                                  ? () => setState(() => _waterEveryDays++)
                                  : null,
                              style: IconButton.styleFrom(
                                backgroundColor: GreenLeafColors.mintTint,
                                foregroundColor: GreenLeafColors.primaryGreen,
                              ),
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: _dayPresets.map((days) {
                            final selected = _waterEveryDays == days;
                            return ChoiceChip(
                              label: Text('${days}d'),
                              selected: selected,
                              showCheckmark: false,
                              selectedColor: GreenLeafColors.softYellow,
                              backgroundColor: GreenLeafColors.appBackground,
                              side: BorderSide(
                                color: selected
                                    ? GreenLeafColors.primaryGreen
                                    : GreenLeafColors.softGreenBorder,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? GreenLeafColors.textPrimary
                                    : GreenLeafColors.textSecondary,
                              ),
                              onSelected: (_) =>
                                  setState(() => _waterEveryDays = days),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Sunlight
                  const _SectionLabel('Sunlight'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sunlightOptions.map((option) {
                      final selected = _selectedSunlight == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: GreenLeafColors.softYellow,
                        backgroundColor: GreenLeafColors.pureWhite,
                        side: BorderSide(
                          color: selected
                              ? GreenLeafColors.warmYellow
                              : GreenLeafColors.softGreenBorder,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? GreenLeafColors.yellowAccentText
                              : GreenLeafColors.textSecondary,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedSunlight = option),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Care Tip
                  const _SectionLabel('Care Note (Optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _careTipController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Mist leaves twice a week',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Due today toggle
                  Material(
                    color: GreenLeafColors.softYellowTint,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: GreenLeafColors.warmYellow),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      value: _needsWaterToday,
                      activeThumbColor: GreenLeafColors.primaryGreen,
                      title: const Text(
                        'Needs watering today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: GreenLeafColors.textPrimary,
                        ),
                      ),
                      subtitle: const Text(
                        'Show on Home screen right away',
                        style: TextStyle(
                          fontSize: 12,
                          color: GreenLeafColors.textSecondary,
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => _needsWaterToday = value),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Save button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : _submit,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: GreenLeafColors.pureWhite,
                              ),
                            )
                          : const Icon(Icons.add_circle_outline_rounded),
                      label: Text(
                        isSaving ? 'Saving...' : 'Add Plant to GreenLeaf',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: GreenLeafColors.textPrimary,
      ),
    );
  }
}

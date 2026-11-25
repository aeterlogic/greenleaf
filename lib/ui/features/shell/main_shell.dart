import 'package:material_ui/material_ui.dart';
import 'package:greenleaf/ui/core/theme/app_theme.dart';
import 'package:greenleaf/ui/features/plants/view_models/plants_view_model.dart';
import 'package:greenleaf/ui/features/plants/views/add_plant_screen.dart';
import 'package:greenleaf/ui/features/plants/views/home_screen.dart';
import 'package:greenleaf/ui/features/plants/views/my_plants_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.viewModel,
  });

  final PlantsViewModel viewModel;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final dueCount = widget.viewModel.dueTodayPlants.length;

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              HomeScreen(
                viewModel: widget.viewModel,
                onGoToAddPlant: () => _selectTab(2),
              ),
              MyPlantsScreen(viewModel: widget.viewModel),
              AddPlantScreen(
                viewModel: widget.viewModel,
                onPlantAdded: ({required bool dueToday}) {
                  _selectTab(dueToday ? 0 : 1);
                },
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: GreenLeafColors.pureWhite,
              border: Border(
                top: BorderSide(
                  color: GreenLeafColors.softGreenBorder,
                  width: 1,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectTab,
              backgroundColor: GreenLeafColors.pureWhite,
              indicatorColor: GreenLeafColors.softYellow,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              height: 68,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: dueCount > 0,
                    label: Text('$dueCount'),
                    backgroundColor: GreenLeafColors.primaryGreen,
                    textColor: GreenLeafColors.pureWhite,
                    child: const Icon(Icons.home_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: dueCount > 0,
                    label: Text('$dueCount'),
                    backgroundColor: GreenLeafColors.primaryGreen,
                    textColor: GreenLeafColors.pureWhite,
                    child: const Icon(
                      Icons.home_rounded,
                      color: GreenLeafColors.primaryGreen,
                    ),
                  ),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.local_florist_outlined),
                  selectedIcon: Icon(
                    Icons.local_florist_rounded,
                    color: GreenLeafColors.primaryGreen,
                  ),
                  label: 'My Plants',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(
                    Icons.add_circle_rounded,
                    color: GreenLeafColors.primaryGreen,
                  ),
                  label: 'Add Plant',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

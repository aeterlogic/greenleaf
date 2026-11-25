import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greenleaf/data/repositories/plant_repository.dart';
import 'package:greenleaf/data/repositories/supabase_plant_repository.dart';
import 'package:greenleaf/ui/core/theme/app_theme.dart';
import 'package:greenleaf/ui/core/widgets/phone_frame_shell.dart';
import 'package:greenleaf/ui/features/plants/view_models/plants_view_model.dart';
import 'package:greenleaf/ui/features/shell/main_shell.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  runApp(
    GreenLeafApp(
      repository: SupabasePlantRepository(client: Supabase.instance.client),
    ),
  );
}

class GreenLeafApp extends StatefulWidget {
  const GreenLeafApp({
    super.key,
    required this.repository,
  });

  final PlantRepository repository;

  @override
  State<GreenLeafApp> createState() => _GreenLeafAppState();
}

class _GreenLeafAppState extends State<GreenLeafApp> {
  late final PlantsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PlantsViewModel(repository: widget.repository);
    _viewModel.loadPlants();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'greenleaf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return PhoneFrameShell(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MainShell(viewModel: _viewModel),
    );
  }
}

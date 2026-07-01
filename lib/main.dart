import 'package:flutter/material.dart';
import 'zmanim_screen.dart';
import 'first_launch_disclaimer.dart';
import 'services/update_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zmanim - Jewish Times',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _AppGate(),
    );
  }
}

/// Gates the app behind the first-launch disclaimer flow.
/// Shows a loading indicator while checking SharedPreferences, then
/// either the disclaimer dialogs (on first launch) or ZmanimScreen directly.
class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await checkAndShowDisclaimers(context);
    if (mounted) {
      // Non-blocking update check — runs after the UI is ready
      UpdateService.runUpdateFlow(context);
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const ZmanimScreen();
  }
}

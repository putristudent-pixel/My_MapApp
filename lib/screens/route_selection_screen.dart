import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../demo_data.dart';
import '../widgets/map_preview.dart';
import '../widgets/shared_widgets.dart';

class RouteSelectionScreen extends StatelessWidget {
  const RouteSelectionScreen({required this.destination, required this.selectedRoute, required this.onBack, required this.onSelectRoute, required this.onStart, super.key});
  final Place destination;
  final RouteChoice selectedRoute;
  final VoidCallback onBack;
  final ValueChanged<RouteChoice> onSelectRoute;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: onBack), title: const Text('Choose your route')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            MapPreview(destination: destination.name, height: 196),
            const SizedBox(height: 18),
            Text('Going to ${destination.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 4),
            const Text('Choose what feels best for you.', style: TextStyle(fontSize: 17, color: AppColors.muted)),
            const SizedBox(height: 18),
            ...routeChoices.map((route) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RouteCard(
                    route: route,
                    selected: route.title == selectedRoute.title,
                    onTap: () => onSelectRoute(route),
                  ),
                )),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.navigation_rounded),
              label: const Text('Start my walk'),
              style: primaryButtonStyle(),
            ),
          ],
        ),
      ),
    );
  }
}

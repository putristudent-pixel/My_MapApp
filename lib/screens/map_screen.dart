import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../demo_data.dart';
import '../widgets/map_preview.dart';
import '../widgets/shared_widgets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    required this.onPickDestination,
    required this.onChoosePlace,
    required this.onTabSelected,
    super.key,
  });

  final VoidCallback onPickDestination;
  final ValueChanged<Place> onChoosePlace;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            const Text(
              'Explore nearby',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 12),
            const MapPreview(height: 300),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onPickDestination,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Choose a destination'),
              style: primaryButtonStyle(),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Nearby saved places'),
            const SizedBox(height: 10),
            ...favoritePlaces.map(
              (place) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PlaceListTile(
                  place: place,
                  onTap: () => onChoosePlace(place),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        onDestinationSelected: onTabSelected,
      ),
    );
  }
}

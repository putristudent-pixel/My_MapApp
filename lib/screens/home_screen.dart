import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../demo_data.dart';
import '../widgets/map_preview.dart';
import '../widgets/shared_widgets.dart';
import 'weather_forecast_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.userName,
    required this.onPickDestination,
    required this.onChoosePlace,
    required this.onPickMap,
    required this.onOpenForecast,
    required this.onTabSelected,
    super.key,
  });

  final String userName;
  final VoidCallback onPickDestination;
  final ValueChanged<Place> onChoosePlace;
  final VoidCallback onPickMap;
  final VoidCallback onOpenForecast;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            Text('Hello, $userName!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 4),
            const Text('Where would you like to go today?', style: TextStyle(fontSize: 17, color: AppColors.muted)),
            const SizedBox(height: 18),
            Semantics(
              button: true,
              label: 'Open map',
              child: GestureDetector(
                onTap: onPickMap,
                child: const MapPreview(height: 210),
              ),
            ),
            const SizedBox(height: 18),
            SectionTitle(title: 'Places you may like', trailing: 'Based on recent visits'),
            const SizedBox(height: 10),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favoritePlaces.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => PlaceShortcut(
                  place: favoritePlaces[index],
                  onTap: () => onChoosePlace(favoritePlaces[index]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPickDestination,
              icon: const Icon(Icons.search_rounded, size: 25),
              label: const Text('Pick a destination'),
              style: primaryButtonStyle(),
            ),
            const SizedBox(height: 16),
            const ReassuranceCard(
              icon: Icons.favorite_rounded,
              text: 'Take your time. We’ll guide you one step at a time.',
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Weather'),
            const SizedBox(height: 8),
            WeatherPreview(onOpenForecast: onOpenForecast),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 1,
        onDestinationSelected: onTabSelected,
      ),
    );
  }
}

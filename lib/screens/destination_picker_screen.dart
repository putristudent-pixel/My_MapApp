import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../demo_data.dart';
import '../widgets/shared_widgets.dart';

class DestinationPickerScreen extends StatefulWidget {
  const DestinationPickerScreen({required this.onBack, required this.onVoiceSearch, required this.onChoosePlace, super.key});
  final VoidCallback onBack;
  final VoidCallback onVoiceSearch;
  final ValueChanged<Place> onChoosePlace;

  @override
  State<DestinationPickerScreen> createState() => _DestinationPickerScreenState();
}

class _DestinationPickerScreenState extends State<DestinationPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final places = favoritePlaces.where((place) => '${place.name} ${place.subtitle}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: widget.onBack), title: const Text('Choose a place')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            const Text('Where would you like to go?', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 6),
            const Text('Search for a place or choose one you know.', style: TextStyle(fontSize: 16, color: AppColors.muted)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      hintText: 'Search places',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 17),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 58,
                  height: 58,
                  child: FilledButton(
                    onPressed: widget.onVoiceSearch,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), padding: EdgeInsets.zero),
                    child: const Icon(Icons.mic_rounded, size: 28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Saved places'),
            const SizedBox(height: 10),
            if (places.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Text('No saved places match that search.', style: TextStyle(fontSize: 17, color: AppColors.muted)),
              )
            else
              ...places.map((place) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PlaceListTile(place: place, onTap: () => widget.onChoosePlace(place)),
                  )),
          ],
        ),
      ),
    );
  }
}

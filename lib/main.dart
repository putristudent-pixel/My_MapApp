import 'package:flutter/material.dart';

import 'demo_data.dart';
import 'widgets/map_preview.dart';

void main() => runApp(const MyMapApp());

const _navy = Color(0xFF20256F);
const _ink = Color(0xFF20242B);
const _muted = Color(0xFF5C626B);
const _cream = Color(0xFFF8F7F2);
const _green = Color(0xFF167A66);

class MyMapApp extends StatelessWidget {
  const MyMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _navy,
      primary: _navy,
      secondary: _green,
      surface: Colors.white,
    );
    return MaterialApp(
      title: 'Kind Way',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _cream,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: _cream,
          foregroundColor: _ink,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(color: _ink, fontSize: 23, fontWeight: FontWeight.w800),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const NavigationFlow(),
    );
  }
}

enum _Stage { home, destinations, routes, navigation, arrived }

class NavigationFlow extends StatefulWidget {
  const NavigationFlow({super.key});

  @override
  State<NavigationFlow> createState() => _NavigationFlowState();
}

class _NavigationFlowState extends State<NavigationFlow> {
  _Stage _stage = _Stage.home;
  Place _destination = favoritePlaces[1];
  RouteChoice _route = routeChoices.first;
  int _step = 0;

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _goHome() => setState(() => _stage = _Stage.home);

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _Stage.home:
        return HomeScreen(
          onPickDestination: () => setState(() => _stage = _Stage.destinations),
          onChoosePlace: (place) => setState(() {
            _destination = place;
            _stage = _Stage.routes;
          }),
          onProfile: () => _message('Your trusted contact is Jennifer.'),
        );
      case _Stage.destinations:
        return DestinationPickerScreen(
          onBack: _goHome,
          onVoiceSearch: () => _message('Voice search is ready to connect.'),
          onChoosePlace: (place) => setState(() {
            _destination = place;
            _stage = _Stage.routes;
          }),
        );
      case _Stage.routes:
        return RouteSelectionScreen(
          destination: _destination,
          selectedRoute: _route,
          onBack: () => setState(() => _stage = _Stage.destinations),
          onSelectRoute: (route) => setState(() => _route = route),
          onStart: () => setState(() {
            _step = 0;
            _stage = _Stage.navigation;
          }),
        );
      case _Stage.navigation:
        return FollowRouteScreen(
          destination: _destination,
          route: _route,
          step: _step,
          onBack: () => setState(() => _stage = _Stage.routes),
          onCall: () => _message('Calling Jennifer… (demo only)'),
          onNext: () => setState(() {
            if (_step < navigationSteps.length - 1) {
              _step++;
            } else {
              _stage = _Stage.arrived;
            }
          }),
        );
      case _Stage.arrived:
        return ArrivalScreen(
          destination: _destination,
          onNotify: () => _message('Jennifer has been told you arrived safely. (Demo)'),
          onHome: _goHome,
        );
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onPickDestination,
    required this.onChoosePlace,
    required this.onProfile,
    super.key,
  });

  final VoidCallback onPickDestination;
  final ValueChanged<Place> onChoosePlace;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
        actions: [
          IconButton(
            tooltip: 'Trusted contact',
            onPressed: onProfile,
            icon: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFE7E6F7),
              child: Icon(Icons.person_rounded, color: _navy),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            Text('Hello, Mama Coco!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 4),
            const Text('Where would you like to go today?', style: TextStyle(fontSize: 17, color: _muted)),
            const SizedBox(height: 18),
            const MapPreview(height: 248),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Your usual places', trailing: 'Tap a place to begin'),
            const SizedBox(height: 10),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favoritePlaces.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => _PlaceShortcut(
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
              style: _primaryButtonStyle(),
            ),
            const SizedBox(height: 16),
            const _ReassuranceCard(
              icon: Icons.favorite_rounded,
              text: 'Take your time. We’ll guide you one step at a time.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

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
            const Text('Where would you like to go?', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 6),
            const Text('Search for a place or choose one you know.', style: TextStyle(fontSize: 16, color: _muted)),
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
                    style: FilledButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), padding: EdgeInsets.zero),
                    child: const Icon(Icons.mic_rounded, size: 28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Saved places'),
            const SizedBox(height: 10),
            if (places.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Text('No saved places match that search.', style: TextStyle(fontSize: 17, color: _muted)),
              )
            else
              ...places.map((place) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlaceListTile(place: place, onTap: () => widget.onChoosePlace(place)),
                  )),
          ],
        ),
      ),
    );
  }
}

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
            Text('Going to ${destination.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 4),
            const Text('Choose what feels best for you.', style: TextStyle(fontSize: 17, color: _muted)),
            const SizedBox(height: 18),
            ...routeChoices.map((route) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RouteCard(
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
              style: _primaryButtonStyle(),
            ),
          ],
        ),
      ),
    );
  }
}

class FollowRouteScreen extends StatelessWidget {
  const FollowRouteScreen({required this.destination, required this.route, required this.step, required this.onBack, required this.onCall, required this.onNext, super.key});
  final Place destination;
  final RouteChoice route;
  final int step;
  final VoidCallback onBack;
  final VoidCallback onCall;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final instruction = navigationSteps[step];
    final isLastStep = step == navigationSteps.length - 1;
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: onBack), title: const Text('Your walk')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: MapPreview(destination: destination.name, height: double.infinity)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(color: const Color(0xFFE8E9FA), borderRadius: BorderRadius.circular(18)),
                          child: Icon(step == 1 ? Icons.turn_right_rounded : Icons.arrow_upward_rounded, color: _navy, size: 36),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Step ${step + 1} of ${navigationSteps.length}', style: const TextStyle(color: _muted, fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(instruction, style: const TextStyle(color: _ink, fontSize: 23, height: 1.15, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('${route.duration} · ${route.title}', style: const TextStyle(color: _muted, fontSize: 16)),
                    const SizedBox(height: 8),
                    const _ReassuranceCard(icon: Icons.check_circle_rounded, text: 'You are on the right track!'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.call_rounded, size: 23),
                label: const Text('Call Jennifer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9A2E2E),
                  side: const BorderSide(color: Color(0xFF9A2E2E), width: 1.5),
                  minimumSize: const Size.fromHeight(54),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: onNext,
                style: _primaryButtonStyle(),
                child: Text(isLastStep ? 'I have arrived' : 'Next step'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArrivalScreen extends StatelessWidget {
  const ArrivalScreen({required this.destination, required this.onNotify, required this.onHome, super.key});
  final Place destination;
  final VoidCallback onNotify;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 124,
                  height: 124,
                  decoration: const BoxDecoration(color: Color(0xFFDCEFE8), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: _green, size: 76),
                ),
                const SizedBox(height: 26),
                const Text('You have arrived safely!', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, height: 1.1, fontWeight: FontWeight.w900, color: _ink)),
                const SizedBox(height: 10),
                Text('You made it to ${destination.name}. Well done!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, color: _muted)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onNotify,
                    icon: const Icon(Icons.message_rounded),
                    label: const Text('Let Jennifer know I’m safe'),
                    style: _primaryButtonStyle(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to home'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceShortcut extends StatelessWidget {
  const _PlaceShortcut({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 106,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(place.icon, color: place.color, size: 30),
                  const SizedBox(height: 6),
                  Text(place.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, color: _ink, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      );
}

class _PlaceListTile extends StatelessWidget {
  const _PlaceListTile({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: place.color.withOpacity(.12), borderRadius: BorderRadius.circular(16)),
                  child: Icon(place.icon, color: place.color, size: 29),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
                      const SizedBox(height: 3),
                      Text(place.subtitle, style: const TextStyle(fontSize: 14, color: _muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: _muted, size: 26),
              ],
            ),
          ),
        ),
      );
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route, required this.selected, required this.onTap});
  final RouteChoice route;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? const Color(0xFFE9EAF8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 82),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? _navy : Colors.transparent, width: 2)),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: route.color.withOpacity(.12), borderRadius: BorderRadius.circular(16)),
                  child: Icon(route.icon, color: route.color, size: 30),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(route.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
                      const SizedBox(height: 2),
                      Text(route.description, style: const TextStyle(fontSize: 14, color: _muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(route.duration, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
              ],
            ),
          ),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _ink)),
          if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 13, color: _muted)),
        ],
      );
}

class _ReassuranceCard extends StatelessWidget {
  const _ReassuranceCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFE8F2ED), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: _green, size: 22),
            const SizedBox(width: 9),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF245344), fontWeight: FontWeight.w600))),
          ],
        ),
      );
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: 0,
        height: 72,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Help'),
        ],
        onDestinationSelected: (index) {
          final message = switch (index) {
            1 => 'Your saved places are ready above.',
            2 => 'For help, tap Call Jennifer during your walk.',
            _ => 'You are viewing nearby places.',
          };
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        },
      );
}

ButtonStyle _primaryButtonStyle() => FilledButton.styleFrom(
      backgroundColor: _navy,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(58),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

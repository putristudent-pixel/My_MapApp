import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../demo_data.dart';

class PlaceShortcut extends StatelessWidget {
  const PlaceShortcut({required this.place, required this.onTap});
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
                  Text(place.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, color: AppColors.ink, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      );
}

class PlaceListTile extends StatelessWidget {
  const PlaceListTile({required this.place, required this.onTap});
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
                  decoration: BoxDecoration(color: place.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
                  child: Icon(place.icon, color: place.color, size: 29),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 3),
                      Text(place.subtitle, style: const TextStyle(fontSize: 14, color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 26),
              ],
            ),
          ),
        ),
      );
}

class RouteCard extends StatelessWidget {
  const RouteCard({required this.route, required this.selected, required this.onTap});
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? AppColors.navy : Colors.transparent, width: 2)),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: route.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
                  child: Icon(route.icon, color: route.color, size: 30),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(route.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 2),
                      Text(route.description, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(route.duration, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
              ],
            ),
          ),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
          if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      );
}

class ReassuranceCard extends StatelessWidget {
  const ReassuranceCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFE8F2ED), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.green, size: 22),
            const SizedBox(width: 9),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF245344), fontWeight: FontWeight.w600))),
          ],
        ),
      );
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: selectedIndex,
        height: 76,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: 'Maps'),
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
        onDestinationSelected: onDestinationSelected,
      );
}

ButtonStyle primaryButtonStyle() => FilledButton.styleFrom(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(58),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

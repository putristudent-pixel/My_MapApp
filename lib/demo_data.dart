import 'package:flutter/material.dart';

class Place {
  const Place({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.distance = 'Nearby',
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String distance;
}

class RouteChoice {
  const RouteChoice({
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final String duration;
  final IconData icon;
  final Color color;
}

const favoritePlaces = <Place>[
  Place(
    name: 'Home',
    subtitle: 'Your saved home address',
    icon: Icons.home_rounded,
    color: Color(0xFF167A66),
    distance: '12 min walk',
  ),
  Place(
    name: 'Pharmacy',
    subtitle: 'Greenleaf Pharmacy · Oak Street',
    icon: Icons.local_pharmacy_rounded,
    color: Color(0xFFB05D21),
    distance: '8 min walk',
  ),
  Place(
    name: 'Park',
    subtitle: 'Willow Creek Community Park',
    icon: Icons.park_rounded,
    color: Color(0xFF527A3C),
    distance: '15 min walk',
  ),
  Place(
    name: 'Grocery store',
    subtitle: 'Market Street Grocers',
    icon: Icons.shopping_basket_rounded,
    color: Color(0xFF5C62A8),
    distance: '10 min walk',
  ),
];

const routeChoices = <RouteChoice>[
  RouteChoice(
    title: 'Easiest walk',
    description: 'Wide sidewalks and gentle turns',
    duration: '12 min',
    icon: Icons.directions_walk_rounded,
    color: Color(0xFF167A66),
  ),
  RouteChoice(
    title: 'Fewest stairs',
    description: 'Step-free paths wherever possible',
    duration: '15 min',
    icon: Icons.accessible_forward_rounded,
    color: Color(0xFF4F5FA8),
  ),
  RouteChoice(
    title: 'Fastest route',
    description: 'The quickest way to get there',
    duration: '9 min',
    icon: Icons.bolt_rounded,
    color: Color(0xFFB05D21),
  ),
];

const navigationSteps = <String>[
  'Head toward Oak Street',
  'Turn right at the library',
  'Continue straight for two blocks',
  'Your destination is on the left',
];

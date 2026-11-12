import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'demo_data.dart';
import 'models.dart';
import 'screens/arrival_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/conversation_screen.dart';
import 'screens/destination_picker_screen.dart';
import 'screens/follow_route_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/route_selection_screen.dart';
import 'screens/weather_forecast_screen.dart';

void main() => runApp(const MyMapApp());

class MyMapApp extends StatelessWidget {
  const MyMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      secondary: AppColors.green,
      surface: Colors.white,
    );
    return MaterialApp(
      title: 'Kind Way',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.cream,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(color: AppColors.ink, fontSize: 23, fontWeight: FontWeight.w800),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const NavigationFlow(),
    );
  }
}

enum _Stage {
  home,
  map,
  chats,
  conversation,
  weatherForecast,
  profile,
  destinations,
  routes,
  navigation,
  arrived,
}

class NavigationFlow extends StatefulWidget {
  const NavigationFlow({super.key});

  @override
  State<NavigationFlow> createState() => _NavigationFlowState();
}

class _NavigationFlowState extends State<NavigationFlow> {
  _Stage _stage = _Stage.home;
  bool _isAuthenticated = false;
  bool _isSignUp = true;
  String _authError = '';
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userPassword = '';
  ChatContact _selectedContact = chatContacts.first;
  Place _destination = favoritePlaces[1];
  RouteChoice _route = routeChoices.first;
  int _step = 0;

  void _authenticate(AuthDetails details) {
    final email = details.email.trim().toLowerCase();
    if (details.isSignUp) {
      setState(() {
        _userName = details.name.trim();
        _userEmail = email;
        _userPhone = details.phone.trim();
        _userPassword = details.password;
        _isAuthenticated = true;
        _authError = '';
      });
      return;
    }

    if (email != _userEmail || details.password != _userPassword) {
      setState(() => _authError = 'That email or password does not match this demo account.');
      return;
    }

    setState(() {
      _isAuthenticated = true;
      _authError = '';
    });
  }

  void _signOut() {
    setState(() {
      _isAuthenticated = false;
      _isSignUp = false;
      _authError = '';
      _stage = _Stage.home;
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _goHome() => setState(() => _stage = _Stage.home);

  void _selectTab(int index) {
    setState(() {
      _stage = switch (index) {
        0 => _Stage.map,
        1 => _Stage.home,
        2 => _Stage.chats,
        _ => _Stage.profile,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return AuthScreen(
        initialIsSignUp: _isSignUp,
        errorMessage: _authError,
        onModeChanged: (isSignUp) => setState(() {
          _isSignUp = isSignUp;
          _authError = '';
        }),
        onSubmit: _authenticate,
      );
    }

    switch (_stage) {
      case _Stage.home:
        return HomeScreen(
          userName: _userName,
          onPickDestination: () => setState(() => _stage = _Stage.destinations),
          onChoosePlace: (place) => setState(() {
            _destination = place;
            _stage = _Stage.routes;
          }),
          onPickMap: () => setState(() => _stage = _Stage.map),
          onOpenForecast: () => setState(() => _stage = _Stage.weatherForecast),
          onTabSelected: _selectTab,
        );
      case _Stage.map:
        return MapScreen(
          onPickDestination: () => setState(() => _stage = _Stage.destinations),
          onChoosePlace: (place) => setState(() {
            _destination = place;
            _stage = _Stage.routes;
          }),
          onTabSelected: _selectTab,
        );
      case _Stage.chats:
        return ChatListScreen(
          onOpenChat: (contact) => setState(() {
            _selectedContact = contact;
            _stage = _Stage.conversation;
          }),
          onTabSelected: _selectTab,
        );
      case _Stage.conversation:
        return ConversationScreen(
          contact: _selectedContact,
          onBack: () => setState(() => _stage = _Stage.chats),
        );
      case _Stage.weatherForecast:
        return WeatherForecastScreen(
          onBack: _goHome,
          onTabSelected: _selectTab,
        );
      case _Stage.profile:
        return ProfileScreen(
          name: _userName,
          email: _userEmail,
          phone: _userPhone,
          onBack: _goHome,
          onSignOut: _signOut,
          onTabSelected: _selectTab,
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
          onCall: (contact) => _message('Calling $contact… (demo only)'),
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
          onNotify: (contact) => _message('$contact has been told you arrived safely. (Demo)'),
          onHome: _goHome,
        );
    }
  }
}

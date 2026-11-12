import 'package:flutter/material.dart';
import 'account_storage.dart';
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

class MyMapApp extends StatefulWidget {
  const MyMapApp({super.key, this.accountStorage});

  final AccountStorage? accountStorage;

  @override
  State<MyMapApp> createState() => _MyMapAppState();
}

class _MyMapAppState extends State<MyMapApp> {
  late AccountStorage _accountStorage;
  late Future<AccountSession?> _accountFuture;

  @override
  void initState() {
    super.initState();
    _accountStorage = widget.accountStorage ?? SecureAccountStorage();
    _accountFuture = _accountStorage.loadAccount();
  }

  @override
  void didUpdateWidget(covariant MyMapApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountStorage != widget.accountStorage) {
      _accountStorage = widget.accountStorage ?? SecureAccountStorage();
      _accountFuture = _accountStorage.loadAccount();
    }
  }

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
      home: FutureBuilder<AccountSession?>(
        future: _accountFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'We could not load your saved account from this device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: AppColors.ink),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => setState(
                            () => _accountFuture = _accountStorage.loadAccount(),
                          ),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(value: 0.25)),
            );
          }
          return NavigationFlow(
            accountStorage: _accountStorage,
            savedAccount: snapshot.data,
          );
        },
      ),
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
  const NavigationFlow({
    required this.accountStorage,
    required this.savedAccount,
    super.key,
  });

  final AccountStorage accountStorage;
  final AccountSession? savedAccount;

  @override
  State<NavigationFlow> createState() => _NavigationFlowState();
}

class _NavigationFlowState extends State<NavigationFlow> {
  _Stage _stage = _Stage.home;
  late bool _isAuthenticated = widget.savedAccount?.isSignedIn ?? false;
  late bool _isSignUp = widget.savedAccount == null;
  String _authError = '';
  late String _userName = widget.savedAccount?.name ?? '';
  late String _userEmail = widget.savedAccount?.email ?? '';
  late String _userPhone = widget.savedAccount?.phone ?? '';
  late String _userPassword = widget.savedAccount?.password ?? '';
  bool _isSubmitting = false;
  ChatContact _selectedContact = chatContacts.first;
  Place _destination = favoritePlaces[1];
  RouteChoice _route = routeChoices.first;
  int _step = 0;

  Future<void> _authenticate(AuthDetails details) async {
    final email = details.email.trim().toLowerCase();
    setState(() {
      _isSubmitting = true;
      _authError = '';
    });

    try {
      if (details.isSignUp) {
        await widget.accountStorage.saveAccount(details);
        if (!mounted) return;
        setState(() {
          _userName = details.name.trim();
          _userEmail = email;
          _userPhone = details.phone.trim();
          _userPassword = details.password;
          _isAuthenticated = true;
        });
        return;
      }

      if (email != _userEmail || details.password != _userPassword) {
        setState(() => _authError = 'That email or password does not match this demo account.');
        return;
      }

      await widget.accountStorage.setSignedIn(true);
      if (!mounted) return;
      setState(() => _isAuthenticated = true);
    } on Exception catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'account storage',
          context: ErrorDescription('while saving or opening the demo account'),
        ),
      );
      if (mounted) {
        setState(
          () => _authError = 'We could not save your account securely on this device. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.accountStorage.setSignedIn(false);
      if (!mounted) return;
      setState(() {
        _isAuthenticated = false;
        _isSignUp = false;
        _authError = '';
        _stage = _Stage.home;
      });
    } on Exception catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'account storage',
          context: ErrorDescription('while signing out of the demo account'),
        ),
      );
      if (mounted) _message('We could not sign you out. Please try again.');
    }
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
        initialEmail: _userEmail,
        isSubmitting: _isSubmitting,
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

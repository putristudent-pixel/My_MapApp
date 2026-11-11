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

class _ChatContact {
  const _ChatContact({
    required this.name,
    required this.preview,
    required this.status,
  });

  final String name;
  final String preview;
  final String status;
}

class _TrustedContact {
  const _TrustedContact({
    required this.name,
    required this.note,
  });

  final String name;
  final String note;
}

const _trustedCallContacts = <_TrustedContact>[
  _TrustedContact(name: 'Jennifer', note: 'Trusted contact'),
  _TrustedContact(name: 'Jay', note: 'Trusted contact'),
  _TrustedContact(name: 'Sarah', note: 'Trusted contact'),
];

const _chatContacts = <_ChatContact>[
  _ChatContact(name: 'Jennifer', preview: 'Let me know when you arrive.', status: 'Online'),
  _ChatContact(name: 'Jay', preview: 'I’m down! Any ideas?', status: 'Last seen 45 mins ago'),
  _ChatContact(name: 'Sarah', preview: 'See you this afternoon!', status: 'Last seen today'),
  _ChatContact(name: 'Michael', preview: 'Thanks for the update.', status: 'Last seen yesterday'),
  _ChatContact(name: 'Community support', preview: 'How can we help you today?', status: 'Usually replies quickly'),
  _ChatContact(name: 'Alex', preview: 'Have a lovely day!', status: 'Last seen yesterday'),
];

class _AuthDetails {
  const _AuthDetails({
    required this.isSignUp,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final bool isSignUp;
  final String name;
  final String email;
  final String phone;
  final String password;
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
  _ChatContact _selectedContact = _chatContacts.first;
  Place _destination = favoritePlaces[1];
  RouteChoice _route = routeChoices.first;
  int _step = 0;

  void _authenticate(_AuthDetails details) {
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
            Text('Hello, $userName!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 4),
            const Text('Where would you like to go today?', style: TextStyle(fontSize: 17, color: _muted)),
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
            _SectionTitle(title: 'Places you may like', trailing: 'Based on recent visits'),
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
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Weather'),
            const SizedBox(height: 8),
            _WeatherPreview(onOpenForecast: onOpenForecast),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: 1,
        onDestinationSelected: onTabSelected,
      ),
    );
  }
}

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
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: _ink),
            ),
            const SizedBox(height: 12),
            const MapPreview(height: 300),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onPickDestination,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Choose a destination'),
              style: _primaryButtonStyle(),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Nearby saved places'),
            const SizedBox(height: 10),
            ...favoritePlaces.map(
              (place) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlaceListTile(
                  place: place,
                  onTap: () => onChoosePlace(place),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: 0,
        onDestinationSelected: onTabSelected,
      ),
    );
  }
}

class _HourlyForecast {
  const _HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
  });

  final String time;
  final String temperature;
  final IconData icon;
}

const _todayForecast = <_HourlyForecast>[
  _HourlyForecast(time: '5 AM', temperature: '16°', icon: Icons.nightlight_round),
  _HourlyForecast(time: '6 AM', temperature: '17°', icon: Icons.wb_twilight_rounded),
  _HourlyForecast(time: '7 AM', temperature: '18°', icon: Icons.wb_sunny_rounded),
  _HourlyForecast(time: '8 AM', temperature: '20°', icon: Icons.wb_sunny_rounded),
  _HourlyForecast(time: '9 AM', temperature: '21°', icon: Icons.cloud_rounded),
  _HourlyForecast(time: '10 AM', temperature: '22°', icon: Icons.cloud_rounded),
];

class _WeatherPreview extends StatelessWidget {
  const _WeatherPreview({required this.onOpenForecast});

  final VoidCallback onOpenForecast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_rounded, color: Color(0xFFE5A227), size: 25),
              SizedBox(width: 8),
              Text(
                'Partly sunny · 18°',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _todayForecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final forecast = _todayForecast[index];
                return SizedBox(
                  width: 58,
                  child: Column(
                    children: [
                      Text(forecast.time, style: const TextStyle(fontSize: 13, color: _muted)),
                      const SizedBox(height: 6),
                      Icon(forecast.icon, color: const Color(0xFFE5A227), size: 25),
                      const SizedBox(height: 4),
                      Text(
                        forecast.temperature,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink),
                      ),
                      if (forecast.time == '8 AM')
                        const Text('Now', style: TextStyle(fontSize: 11, color: _green)),
                    ],
                  ),
                );
              },
            ),
          ),
          OutlinedButton.icon(
            onPressed: onOpenForecast,
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('View weather forecast'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sample forecast for the demo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }
}

class WeatherForecastScreen extends StatelessWidget {
  const WeatherForecastScreen({
    required this.onBack,
    required this.onTabSelected,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),
        title: const Text('Weather forecast'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(Icons.wb_sunny_rounded, color: Color(0xFFE5A227), size: 56),
                  SizedBox(height: 8),
                  Text('Today · Partly sunny', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
                  Text('18° now · High 22° · Low 16°', style: TextStyle(fontSize: 16, color: _muted)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Today by the hour'),
            const SizedBox(height: 10),
            ..._todayForecast.map(
              (forecast) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      SizedBox(width: 64, child: Text(forecast.time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink))),
                      Icon(forecast.icon, color: const Color(0xFFE5A227)),
                      const Spacer(),
                      Text(forecast.temperature, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const _ReassuranceCard(
              icon: Icons.info_outline_rounded,
              text: 'This is sample weather for the demo, not a live forecast.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: 1,
        onDestinationSelected: onTabSelected,
      ),
    );
  }
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    required this.onOpenChat,
    required this.onTabSelected,
    super.key,
  });

  final ValueChanged<_ChatContact> onOpenChat;
  final ValueChanged<int> onTabSelected;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _searching = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final contacts = _chatContacts
        .where((contact) =>
            '${contact.name} ${contact.preview}'.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search chats', border: InputBorder.none),
                onChanged: (value) => setState(() => _query = value),
              )
            : const Text('Chats'),
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search chats',
            onPressed: () => setState(() {
              _searching = !_searching;
              _query = '';
            }),
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: contacts.isEmpty
            ? const Center(child: Text('No chats match your search.', style: TextStyle(fontSize: 16, color: _muted)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                itemCount: contacts.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    key: ValueKey('chat-${contact.name}'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    leading: const CircleAvatar(
                      radius: 27,
                      backgroundColor: Color(0xFFE7E6F7),
                      child: Icon(Icons.person_outline_rounded, color: _navy, size: 30),
                    ),
                    title: Text(contact.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
                    subtitle: Text(contact.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: _muted)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
                    onTap: () => widget.onOpenChat(contact),
                  );
                },
              ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: 2,
        onDestinationSelected: widget.onTabSelected,
      ),
    );
  }
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    required this.contact,
    required this.onBack,
    super.key,
  });

  final _ChatContact contact;
  final VoidCallback onBack;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _messageController = TextEditingController();
  final _messages = <(String, bool)>[
    ('Hi there! How are you?', false),
    ('I’m doing well, thanks for checking in.', true),
    ('Let me know if you need anything.', false),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _messages.add((message, true));
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onBack),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 21,
              backgroundColor: Color(0xFFE7E6F7),
              child: Icon(Icons.person_rounded, color: _navy),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contact.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
                  Text(widget.contact.status, style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(tooltip: 'Video call', onPressed: () => _showCallMessage('Video'), icon: const Icon(Icons.videocam_outlined)),
          IconButton(tooltip: 'Call', onPressed: () => _showCallMessage('Voice'), icon: const Icon(Icons.call_outlined)),
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$value is not available in this demo.')));
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Chat details', child: Text('Chat details')),
              PopupMenuItem(value: 'Clear chat', child: Text('Clear chat')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final (text, isMine) = _messages[index];
                  return Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                      decoration: BoxDecoration(
                        color: isMine ? _navy : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(text, style: TextStyle(fontSize: 16, color: isMine ? Colors.white : _ink)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('chat-message-input'),
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Write a message',
                        prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white, minimumSize: const Size(52, 52)),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallMessage(String callType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$callType calling is not available in this demo.')),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.initialIsSignUp,
    required this.errorMessage,
    required this.onModeChanged,
    required this.onSubmit,
    super.key,
  });

  final bool initialIsSignUp;
  final String errorMessage;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<_AuthDetails> onSubmit;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late bool _isSignUp = widget.initialIsSignUp;

  @override
  void didUpdateWidget(covariant AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsSignUp != widget.initialIsSignUp) {
      _isSignUp = widget.initialIsSignUp;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Enter your $label.';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_AuthDetails(
      isSignUp: _isSignUp,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                children: [
                  Center(
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(color: _navy, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Text('KW', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Create your account' : 'Welcome back',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: _ink),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'A simple demo account to personalize your walks.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: _muted),
                        ),
                        const SizedBox(height: 22),
                        if (_isSignUp) ...[
                          TextFormField(
                            key: const ValueKey('auth-name'),
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            decoration: _authInputDecoration('Full name'),
                            validator: (value) => _required(value, 'name'),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          key: const ValueKey('auth-email'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: _authInputDecoration('Email'),
                          validator: (value) {
                            final requiredError = _required(value, 'email');
                            if (requiredError != null) return requiredError;
                            if (!value!.contains('@') || !value.contains('.')) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        if (_isSignUp) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const ValueKey('auth-phone'),
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [AutofillHints.telephoneNumber],
                            decoration: _authInputDecoration('Phone number'),
                            validator: (value) => _required(value, 'phone number'),
                          ),
                        ],
                        const SizedBox(height: 14),
                        TextFormField(
                          key: const ValueKey('auth-password'),
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: [_isSignUp ? AutofillHints.newPassword : AutofillHints.password],
                          decoration: _authInputDecoration('Password'),
                          validator: (value) {
                            final requiredError = _required(value, 'password');
                            if (requiredError != null) return requiredError;
                            if (_isSignUp && value!.length < 6) {
                              return 'Use at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        if (_isSignUp) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const ValueKey('auth-confirm-password'),
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: _authInputDecoration('Confirm password'),
                            validator: (value) {
                              final requiredError = _required(value, 'password confirmation');
                              if (requiredError != null) return requiredError;
                              if (value != _passwordController.text) return 'Passwords do not match.';
                              return null;
                            },
                          ),
                        ],
                        if (widget.errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            widget.errorMessage,
                            style: const TextStyle(color: Color(0xFF9A2E2E), fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _submit,
                          style: _primaryButtonStyle(),
                          child: Text(_isSignUp ? 'Create account' : 'Sign in'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() => _isSignUp = !_isSignUp);
                            widget.onModeChanged(_isSignUp);
                          },
                          child: Text(_isSignUp ? 'Already have an account? Sign in' : 'New here? Create an account'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Demo only: account details are kept in memory and are not sent to a service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _authInputDecoration(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _cream,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8D9DF)),
      ),
    );

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.name,
    required this.email,
    required this.phone,
    required this.onBack,
    required this.onSignOut,
    required this.onTabSelected,
    super.key,
  });

  final String name;
  final String email;
  final String phone;
  final VoidCallback onBack;
  final VoidCallback onSignOut;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFFE7E6F7),
                    child: Icon(Icons.person_rounded, color: _navy, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: _ink)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 15, color: _muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _SectionTitle(title: 'Account information'),
            const SizedBox(height: 10),
            _ProfileDetail(icon: Icons.person_outline_rounded, label: 'Name', value: name),
            const SizedBox(height: 8),
            _ProfileDetail(icon: Icons.email_outlined, label: 'Email', value: email),
            const SizedBox(height: 8),
            _ProfileDetail(icon: Icons.phone_outlined, label: 'Phone number', value: phone),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: 3,
        onDestinationSelected: onTabSelected,
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Icon(icon, color: _navy, size: 25),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, color: _muted)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
                ],
              ),
            ),
          ],
        ),
      );
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
  final ValueChanged<String> onCall;
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
                onPressed: () async {
                  final contact = await _showTrustedContactPicker(
                    context,
                    title: 'Who would you like to call?',
                    description: 'Choose one of your trusted contacts.',
                    actionIcon: Icons.call_rounded,
                  );
                  if (contact != null) onCall(contact.name);
                },
                icon: const Icon(Icons.call_rounded, size: 23),
                label: const Text('Call a trusted contact'),
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
  final ValueChanged<String> onNotify;
  final VoidCallback onHome;

  Future<void> _chooseContactToNotify(BuildContext context) async {
    final contact = await _showTrustedContactPicker(
      context,
      title: 'Who should know you arrived safely?',
      description: 'Choose a trusted contact to notify.',
      actionIcon: Icons.message_rounded,
    );
    if (contact != null) onNotify(contact.name);
  }

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
                    onPressed: () => _chooseContactToNotify(context),
                    icon: const Icon(Icons.message_rounded),
                    label: const Text('Let someone know I’m safe'),
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

Future<_TrustedContact?> _showTrustedContactPicker(
  BuildContext context, {
  required String title,
  required String description,
  required IconData actionIcon,
}) {
  return showModalBottomSheet<_TrustedContact>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _ink),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 16, color: _muted)),
            const SizedBox(height: 12),
            ..._trustedCallContacts.map(
              (contact) => ListTile(
                key: ValueKey('trusted-contact-${contact.name}'),
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE7E6F7),
                  child: Icon(Icons.person_rounded, color: _navy),
                ),
                title: Text(
                  contact.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(contact.note),
                trailing: Icon(actionIcon, color: _green),
                onTap: () => Navigator.pop(context, contact),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'This action is simulated in the demo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _muted),
            ),
          ],
        ),
      ),
    ),
  );
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
                  decoration: BoxDecoration(color: place.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
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
                  decoration: BoxDecoration(color: route.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
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
  const _BottomNavBar({
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

ButtonStyle _primaryButtonStyle() => FilledButton.styleFrom(
      backgroundColor: _navy,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(58),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

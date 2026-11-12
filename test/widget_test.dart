import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_map_app/account_storage.dart';
import 'package:my_map_app/main.dart';
import 'package:my_map_app/models.dart';

class _MemoryAccountStorage implements AccountStorage {
  AccountSession? account;

  @override
  Future<AccountSession?> loadAccount() async => account;

  @override
  Future<void> saveAccount(AuthDetails details) async {
    account = AccountSession(
      name: details.name.trim(),
      email: details.email.trim().toLowerCase(),
      phone: details.phone.trim(),
      password: details.password,
      isSignedIn: true,
    );
  }

  @override
  Future<void> setSignedIn(bool isSignedIn) async {
    final savedAccount = account;
    if (savedAccount == null) {
      throw StateError('Cannot update sign-in state without a saved account.');
    }
    account = savedAccount.copyWith(isSignedIn: isSignedIn);
  }
}

void _useTallTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _createAccount(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const ValueKey('auth-name')));
  await tester.enterText(
      find.byKey(const ValueKey('auth-name')), 'Ada Lovelace');
  await tester.ensureVisible(find.byKey(const ValueKey('auth-email')));
  await tester.enterText(
      find.byKey(const ValueKey('auth-email')), 'ada@example.com');
  await tester.ensureVisible(find.byKey(const ValueKey('auth-phone')));
  await tester.enterText(
      find.byKey(const ValueKey('auth-phone')), '5551234567');
  await tester.ensureVisible(find.byKey(const ValueKey('auth-password')));
  await tester.enterText(
      find.byKey(const ValueKey('auth-password')), 'example123');
  await tester
      .ensureVisible(find.byKey(const ValueKey('auth-confirm-password')));
  await tester.enterText(
      find.byKey(const ValueKey('auth-confirm-password')), 'example123');
  final createAccountButton = find.ancestor(
    of: find.text('Create account'),
    matching: find.byType(FilledButton),
  );
  await tester.ensureVisible(createAccountButton);
  await tester.tap(createAccountButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign up greets the user and opens their profile',
      (tester) async {
    _useTallTestViewport(tester);
    final storage = _MemoryAccountStorage();
    await tester.pumpWidget(MyMapApp(accountStorage: storage));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    await _createAccount(tester);

    expect(find.text('Hello, Ada Lovelace!'), findsOneWidget);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Account information'), findsOneWidget);
    expect(find.text('ada@example.com'), findsWidgets);
    expect(find.text('5551234567'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('auth-email')));
    await tester.enterText(
        find.byKey(const ValueKey('auth-email')), 'ada@example.com');
    await tester.ensureVisible(find.byKey(const ValueKey('auth-password')));
    await tester.enterText(
        find.byKey(const ValueKey('auth-password')), 'example123');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Ada Lovelace!'), findsOneWidget);
  });

  testWidgets('home screen opens the destination picker', (tester) async {
    _useTallTestViewport(tester);
    await tester.pumpWidget(MyMapApp(accountStorage: _MemoryAccountStorage()));
    await tester.pumpAndSettle();
    await _createAccount(tester);

    expect(find.text('Hello, Ada Lovelace!'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Partly sunny · 18°'), findsOneWidget);
    await tester.ensureVisible(find.text('View weather forecast'));
    await tester.tap(find.text('View weather forecast'));
    await tester.pumpAndSettle();
    expect(find.text('Today by the hour'), findsOneWidget);
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chat').last);
    await tester.pumpAndSettle();
    expect(find.text('Chats'), findsOneWidget);
    await tester.tap(find.text('Jennifer').first);
    await tester.pumpAndSettle();
    expect(find.text('Let me know if you need anything.'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('chat-message-input')), 'On my way!');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('On my way!'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pick a destination'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a place'), findsOneWidget);
    expect(find.text('Pharmacy'), findsOneWidget);
  });

  testWidgets('user can choose a place and start a walk', (tester) async {
    _useTallTestViewport(tester);
    await tester.pumpWidget(MyMapApp(accountStorage: _MemoryAccountStorage()));
    await tester.pumpAndSettle();
    await _createAccount(tester);
    await tester.tap(find.text('Pick a destination'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Park').last);
    await tester.pumpAndSettle();

    expect(find.text('Going to Park'), findsOneWidget);
    await tester.tap(find.text('Start my walk'));
    await tester.pumpAndSettle();
    expect(find.text('Head toward Oak Street'), findsOneWidget);

    await tester.tap(find.text('Call a trusted contact'));
    await tester.pumpAndSettle();
    expect(find.text('Who would you like to call?'), findsOneWidget);
    expect(find.text('Jennifer'), findsOneWidget);
    expect(find.text('Jay'), findsOneWidget);
    expect(find.text('Sarah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('trusted-contact-Jay')));
    await tester.pumpAndSettle();
    expect(find.text('Calling Jay… (demo only)'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next step'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next step'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next step'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I have arrived'));
    await tester.pumpAndSettle();
    expect(find.text('Let someone know I’m safe'), findsOneWidget);

    await tester.tap(find.text('Let someone know I’m safe'));
    await tester.pumpAndSettle();
    expect(find.text('Who should know you arrived safely?'), findsOneWidget);
    expect(find.text('Jennifer'), findsOneWidget);
    expect(find.text('Jay'), findsOneWidget);
    expect(find.text('Sarah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('trusted-contact-Sarah')));
    await tester.pumpAndSettle();
    expect(find.text('Sarah has been told you arrived safely. (Demo)'),
        findsOneWidget);
  });

  testWidgets('account and sign-in state persist across app restarts',
      (tester) async {
    _useTallTestViewport(tester);
    final storage = _MemoryAccountStorage();
    await tester.pumpWidget(MyMapApp(
      key: const ValueKey('first-launch'),
      accountStorage: storage,
    ));
    await tester.pumpAndSettle();
    await _createAccount(tester);

    expect(find.text('Hello, Ada Lovelace!'), findsOneWidget);
    await tester.pumpWidget(MyMapApp(
      key: const ValueKey('second-launch'),
      accountStorage: storage,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Ada Lovelace!'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.pumpWidget(MyMapApp(
      key: const ValueKey('signed-out-launch'),
      accountStorage: storage,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('auth-email')))
          .controller!
          .text,
      'ada@example.com',
    );
  });
}

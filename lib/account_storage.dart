import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models.dart';

class AccountSession {
  const AccountSession({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.isSignedIn,
  });

  final String name;
  final String email;
  final String phone;
  final String password;
  final bool isSignedIn;

  AccountSession copyWith({bool? isSignedIn}) => AccountSession(
        name: name,
        email: email,
        phone: phone,
        password: password,
        isSignedIn: isSignedIn ?? this.isSignedIn,
      );
}

abstract interface class AccountStorage {
  Future<AccountSession?> loadAccount();
  Future<void> saveAccount(AuthDetails details);
  Future<void> setSignedIn(bool isSignedIn);
}

class SecureAccountStorage implements AccountStorage {
  SecureAccountStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accountKey = 'kind_way_account_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<AccountSession?> loadAccount() async {
    final savedValue = await _storage.read(key: _accountKey);
    if (savedValue == null) return null;

    final decoded = jsonDecode(savedValue);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved account data has an invalid format.');
    }

    final name = decoded['name'];
    final email = decoded['email'];
    final phone = decoded['phone'];
    final password = decoded['password'];
    final isSignedIn = decoded['isSignedIn'];
    if (name is! String ||
        email is! String ||
        phone is! String ||
        password is! String ||
        isSignedIn is! bool) {
      throw const FormatException('Saved account data is incomplete.');
    }

    return AccountSession(
      name: name,
      email: email,
      phone: phone,
      password: password,
      isSignedIn: isSignedIn,
    );
  }

  @override
  Future<void> saveAccount(AuthDetails details) {
    return _writeAccount(
      AccountSession(
        name: details.name.trim(),
        email: details.email.trim().toLowerCase(),
        phone: details.phone.trim(),
        password: details.password,
        isSignedIn: true,
      ),
    );
  }

  @override
  Future<void> setSignedIn(bool isSignedIn) async {
    final account = await loadAccount();
    if (account == null) {
      throw StateError('Cannot update sign-in state without a saved account.');
    }
    await _writeAccount(account.copyWith(isSignedIn: isSignedIn));
  }

  Future<void> _writeAccount(AccountSession account) {
    return _storage.write(
      key: _accountKey,
      value: jsonEncode({
        'name': account.name,
        'email': account.email,
        'phone': account.phone,
        'password': account.password,
        'isSignedIn': account.isSignedIn,
      }),
    );
  }
}

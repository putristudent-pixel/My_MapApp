import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';

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
  final ValueChanged<AuthDetails> onSubmit;

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
    widget.onSubmit(AuthDetails(
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
                      decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
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
                          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: AppColors.ink),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'A simple demo account to personalize your walks.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: AppColors.muted),
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
                          style: primaryButtonStyle(),
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
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
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
      fillColor: AppColors.cream,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8D9DF)),
      ),
    );

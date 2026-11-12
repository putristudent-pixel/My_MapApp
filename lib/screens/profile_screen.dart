import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/shared_widgets.dart';

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
                    child: Icon(Icons.person_rounded, color: AppColors.navy, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.ink)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 15, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionTitle(title: 'Account information'),
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
      bottomNavigationBar: AppBottomNavBar(
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
            Icon(icon, color: AppColors.navy, size: 25),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ],
              ),
            ),
          ],
        ),
      );
}

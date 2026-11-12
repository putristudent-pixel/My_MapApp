import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../demo_data.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/trusted_contact_picker.dart';

class ArrivalScreen extends StatelessWidget {
  const ArrivalScreen(
      {required this.destination,
      required this.onNotify,
      required this.onHome,
      super.key});
  final Place destination;
  final ValueChanged<String> onNotify;
  final VoidCallback onHome;

  Future<void> _chooseContactToNotify(BuildContext context) async {
    final contact = await showTrustedContactPicker(
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
                  decoration: const BoxDecoration(
                      color: Color(0xFFDCEFE8), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.green, size: 76),
                ),
                const SizedBox(height: 26),
                const Text('You have arrived safely!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink)),
                const SizedBox(height: 10),
                Text('You made it to ${destination.name}. Well done!',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 19, color: AppColors.muted)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _chooseContactToNotify(context),
                    icon: const Icon(Icons.message_rounded),
                    label: const Text('Let someone know I’m safe'),
                    style: primaryButtonStyle(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to home'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
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

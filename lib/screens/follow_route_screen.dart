import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../demo_data.dart';
import '../widgets/map_preview.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/trusted_contact_picker.dart';

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
                          child: Icon(step == 1 ? Icons.turn_right_rounded : Icons.arrow_upward_rounded, color: AppColors.navy, size: 36),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Step ${step + 1} of ${navigationSteps.length}', style: const TextStyle(color: AppColors.muted, fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(instruction, style: const TextStyle(color: AppColors.ink, fontSize: 23, height: 1.15, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('${route.duration} · ${route.title}', style: const TextStyle(color: AppColors.muted, fontSize: 16)),
                    const SizedBox(height: 8),
                    const ReassuranceCard(icon: Icons.check_circle_rounded, text: 'You are on the right track!'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final contact = await showTrustedContactPicker(
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
                style: primaryButtonStyle(),
                child: Text(isLastStep ? 'I have arrived' : 'Next step'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

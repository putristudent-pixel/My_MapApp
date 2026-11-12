import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';

Future<TrustedContact?> showTrustedContactPicker(
  BuildContext context, {
  required String title,
  required String description,
  required IconData actionIcon,
}) {
  return showModalBottomSheet<TrustedContact>(
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 16, color: AppColors.muted)),
            const SizedBox(height: 12),
            ...trustedCallContacts.map(
              (contact) => ListTile(
                key: ValueKey('trusted-contact-${contact.name}'),
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE7E6F7),
                  child: Icon(Icons.person_rounded, color: AppColors.navy),
                ),
                title: Text(
                  contact.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(contact.note),
                trailing: Icon(actionIcon, color: AppColors.green),
                onTap: () => Navigator.pop(context, contact),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'This action is simulated in the demo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

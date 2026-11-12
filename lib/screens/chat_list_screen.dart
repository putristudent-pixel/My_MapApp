import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    required this.onOpenChat,
    required this.onTabSelected,
    super.key,
  });

  final ValueChanged<ChatContact> onOpenChat;
  final ValueChanged<int> onTabSelected;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _searching = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final contacts = chatContacts
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
            ? const Center(child: Text('No chats match your search.', style: TextStyle(fontSize: 16, color: AppColors.muted)))
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
                      child: Icon(Icons.person_outline_rounded, color: AppColors.navy, size: 30),
                    ),
                    title: Text(contact.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    subtitle: Text(contact.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                    onTap: () => widget.onOpenChat(contact),
                  );
                },
              ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 2,
        onDestinationSelected: widget.onTabSelected,
      ),
    );
  }
}

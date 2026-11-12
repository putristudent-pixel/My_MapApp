import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    required this.contact,
    required this.onBack,
    super.key,
  });

  final ChatContact contact;
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
              child: Icon(Icons.person_rounded, color: AppColors.navy),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contact.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  Text(widget.contact.status, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
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
                        color: isMine ? AppColors.navy : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(text, style: TextStyle(fontSize: 16, color: isMine ? Colors.white : AppColors.ink)),
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
                    style: IconButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white, minimumSize: const Size(52, 52)),
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

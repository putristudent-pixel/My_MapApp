

class ChatContact {
  const ChatContact({
    required this.name,
    required this.preview,
    required this.status,
  });

  final String name;
  final String preview;
  final String status;
}

class TrustedContact {
  const TrustedContact({
    required this.name,
    required this.note,
  });

  final String name;
  final String note;
}

const trustedCallContacts = <TrustedContact>[
  TrustedContact(name: 'Jennifer', note: 'Trusted contact'),
  TrustedContact(name: 'Jay', note: 'Trusted contact'),
  TrustedContact(name: 'Sarah', note: 'Trusted contact'),
];

const chatContacts = <ChatContact>[
  ChatContact(name: 'Jennifer', preview: 'Let me know when you arrive.', status: 'Online'),
  ChatContact(name: 'Jay', preview: 'I’m down! Any ideas?', status: 'Last seen 45 mins ago'),
  ChatContact(name: 'Sarah', preview: 'See you this afternoon!', status: 'Last seen today'),
  ChatContact(name: 'Michael', preview: 'Thanks for the update.', status: 'Last seen yesterday'),
  ChatContact(name: 'Community support', preview: 'How can we help you today?', status: 'Usually replies quickly'),
  ChatContact(name: 'Alex', preview: 'Have a lovely day!', status: 'Last seen yesterday'),
];

class AuthDetails {
  const AuthDetails({
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

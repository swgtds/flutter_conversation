import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart'; 
import 'screens/messages_screen.dart';
import 'cometchat_config.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CometChat UI Kit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> _initializeAndLogin() async {
    final settings = UIKitSettingsBuilder()
      ..subscriptionType = CometChatSubscriptionType.allUsers
      ..autoEstablishSocketConnection = true
      ..appId = CometChatConfig.appId
      ..region = CometChatConfig.region
      ..authKey = CometChatConfig.authKey
      ..extensions = CometChatUIKitChatExtensions.getDefaultExtensions() 
      ..callingExtension = CometChatCallingExtension(); 

    await CometChatUIKit.init(uiKitSettings: settings.build());
    await CometChatUIKit.login(
      'cometchat-uid-1',
      onSuccess: (_) => debugPrint('✅ Login Successful'),
      onError: (err) => throw Exception('Login Failed: $err'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeAndLogin(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Text(
                  'Error starting app:\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return const ConversationsPage();
      },
    );
  }
}

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CometChatConversations(
          showBackButton: true,
          onItemTap: (conversation) {
            
            final target = conversation.conversationWith;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MessagesScreen(
                  user: target is User ? target : null,
                  group: target is Group ? target : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
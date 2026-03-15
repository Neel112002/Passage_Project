import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/models/conversation_model.dart';
import 'package:passage/nav.dart';
import 'package:passage/theme.dart';
import 'package:passage/widgets/conversation_card.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late List<ConversationModel> _conversations;

  @override
  void initState() {
    super.initState();
    _conversations = ConversationModel.generateSamples(count: 14);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Messages', style: text.titleLarge?.semiBold)),
      body: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final convo = _conversations[index];
          return Column(children: [
            ConversationCard(
              conversation: convo,
              onTap: () => context.push(AppRoutes.chat, extra: convo),
            ),
            Divider(height: 1, thickness: 0.7, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
          ]);
        },
      ),
    );
  }
}

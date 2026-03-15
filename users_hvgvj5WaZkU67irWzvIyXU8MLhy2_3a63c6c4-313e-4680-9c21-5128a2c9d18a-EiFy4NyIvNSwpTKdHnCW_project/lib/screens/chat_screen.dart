import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/models/conversation_model.dart';
import 'package:passage/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.item, this.conversation}) : assert(item != null || conversation != null, 'Either item or conversation must be provided');
  final ItemModel? item;
  final ConversationModel? conversation;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  late final ItemModel _item; // Resolved item from either direct prop or conversation

  @override
  void initState() {
    super.initState();
    _item = widget.item ?? widget.conversation!.item;
    _seedMockConversation();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(jump: true));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _seedMockConversation() {
    final me = 'You';
    final seller = _item.sellerName;
    final title = _item.title;
    final price = _item.displayPrice;

    _messages.addAll([
      _ChatMessage(sender: seller, text: 'Hi! The $title is available.', isMe: false, timestamp: DateTime.now().subtract(const Duration(minutes: 12))),
      _ChatMessage(sender: me, text: 'Awesome! Is the price negotiable?', isMe: true, timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
      _ChatMessage(sender: seller, text: 'I can do $price, it\'s in ${_item.conditionLabel} condition.', isMe: false, timestamp: DateTime.now().subtract(const Duration(minutes: 8))),
      _ChatMessage(sender: me, text: 'Sounds good. Could we meet near ${_item.university}?', isMe: true, timestamp: DateTime.now().subtract(const Duration(minutes: 6))),
      _ChatMessage(sender: seller, text: 'Yes, that works for me this afternoon.', isMe: false, timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
    ]);
  }

  void _sendMessage([String? override]) {
    final text = (override ?? _textController.text).trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(sender: 'You', text: text, isMe: true, timestamp: DateTime.now()));
      _textController.clear();
    });
    _scrollToBottom();
  }

  void _scrollToBottom({bool jump = false}) {
    try {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position.maxScrollExtent + 80;
      if (jump) {
        _scrollController.jumpTo(position);
      } else {
        _scrollController.animateTo(position, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    } catch (e) {
      debugPrint('Scroll error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        titleSpacing: 0,
        title: Row(children: [
          CircleAvatar(backgroundColor: _item.avatarColor, child: Text(_item.initials, style: text.labelLarge?.copyWith(color: Colors.white))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(_item.sellerName, style: text.titleMedium?.semiBold, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.school, size: 14, color: colors.tertiary),
                const SizedBox(width: 4),
                Flexible(child: Text(_item.university, style: text.labelSmall?.withColor(colors.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isFirstInGroup = index == 0 || _messages[index - 1].isMe != msg.isMe;
              final isLastInGroup = index == _messages.length - 1 || _messages[index + 1].isMe != msg.isMe;
              return Padding(
                padding: EdgeInsets.only(
                  top: isFirstInGroup ? AppSpacing.sm : 2,
                  bottom: isLastInGroup ? AppSpacing.sm : 2,
                ),
                child: Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: _ChatBubble(message: msg),
                ),
              );
            },
          ),
        ),
        _ChatInput(
          controller: _textController,
          focusNode: _inputFocus,
          onSend: _sendMessage,
        ),
      ]),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.focusNode, required this.onSend});
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function([String?]) onSend;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outline.withValues(alpha: 0.15), width: 0.8)),
        ),
        child: Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: text.bodyMedium?.withColor(colors.onSurfaceVariant),
                  border: InputBorder.none,
                ),
                onSubmitted: (v) => onSend(v),
                minLines: 1,
                maxLines: 4,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: colors.primary,
            shape: const StadiumBorder(),
            child: InkWell(
              onTap: () => onSend(),
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.send_rounded, size: 20, color: colors.onPrimary),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMe = message.isMe;

    final bg = isMe ? colors.primary : colors.surfaceContainerHighest;
    final fg = isMe ? colors.onPrimary : colors.onSurface;

    BorderRadius radius(bool isMe) => BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isMe ? AppRadius.lg : AppRadius.sm),
          bottomRight: Radius.circular(isMe ? AppRadius.sm : AppRadius.lg),
        );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.74),
      child: DecoratedBox(
        decoration: BoxDecoration(color: bg, borderRadius: radius(isMe)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Text(message.text, style: textTheme.bodyMedium?.withColor(fg)),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String sender;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  _ChatMessage({required this.sender, required this.text, required this.isMe, required this.timestamp});
}

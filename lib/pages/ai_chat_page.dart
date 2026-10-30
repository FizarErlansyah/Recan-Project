import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/chat_message.dart';
import 'package:mobile_apps_recan/services/ai_chat_service.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/widgets/ai_chat_app_bar.dart';
import 'package:mobile_apps_recan/widgets/chat_bubble.dart';
import 'package:mobile_apps_recan/widgets/chat_suggestion_chips.dart';
import 'package:mobile_apps_recan/widgets/slide_up_page_route.dart';
import 'package:mobile_apps_recan/widgets/typing_indicator.dart';

class AiChatPage extends StatefulWidget {
  const new({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(SlideUpPageRoute(page: const AiChatPage()));

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  ChatMessage? _typingMessage;
  bool _isWaiting = false;

  @override
  void initState() {
    super.initState();
    final greeting = ChatMessage(
      isSentByUser: false,
      text: AiChatService.greeting,
      timestamp: DateTime.now(),
    );
    _messages.add(greeting);
    _typingMessage = greeting;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _send(String text) async {
    if (_isWaiting) return;

    setState(() {
      _messages.add(
        ChatMessage(isSentByUser: true, text: text, timestamp: DateTime.now()),
      );
      _typingMessage = null;
      _isWaiting = true;
    });
    _scrollToBottom();

    try {
      final reply = await AiChatService.send(text);
      if (!mounted) return;
      final message = ChatMessage(
        isSentByUser: false,
        text: reply,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(message);
        _typingMessage = message;
        _isWaiting = false;
      });
      _scrollToBottom();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isWaiting = false;
      });
      AppSnackBar.show(context, error.message);
    }
  }

  void _clearTypingMessage() {
    if (!mounted || _typingMessage == null) return;
    setState(() {
      _typingMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _messages.length + (_isWaiting ? 1 : 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AiChatAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              itemCount: itemCount,
              itemBuilder: (context, i) {
                if (i >= _messages.length) return const TypingIndicator();
                final message = _messages[i];
                return ChatBubble(
                  key: ObjectKey(message),
                  message: message,
                  animateTyping: identical(message, _typingMessage),
                  onTypingDone: _clearTypingMessage,
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: ChatSuggestionChips(
              topics: AiChatService.topics,
              enabled: !_isWaiting,
              onSelected: _send,
            ),
          ),
        ],
      ),
    );
  }
}

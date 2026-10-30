import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/chat_message.dart';
import 'package:mobile_apps_recan/widgets/ai_avatar.dart';
import 'package:mobile_apps_recan/widgets/typewriter_text.dart';

class ChatBubble extends StatelessWidget {
  const new({
    required this.message,
    super.key,
    this.animateTyping = false,
    this.onTypingTick,
    this.onTypingDone,
  });

  final ChatMessage message;
  final bool animateTyping;
  final VoidCallback? onTypingTick;
  final VoidCallback? onTypingDone;

  static const Radius _round = Radius.circular(16);
  static const Radius _tail = Radius.circular(4);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isSentByUser;
    final textTheme = Theme.of(context).textTheme;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;
    final textStyle = textTheme.bodyMedium?.copyWith(
      color: isUser ? AppColors.white : AppColors.textPrimary,
      height: 1.45,
    );

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primary
            : AppColors.primarySoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.only(
          topLeft: _round,
          topRight: _round,
          bottomLeft: isUser ? _round : _tail,
          bottomRight: isUser ? _tail : _round,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: animateTyping
          ? TypewriterText(
              text: message.text,
              style: textStyle,
              onTick: onTypingTick,
              onDone: onTypingDone,
            )
          : Text(message.text, style: textStyle),
    );

    final content = Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        bubble,
        const SizedBox(height: 4),
        Text(message.timeLabel, style: textTheme.bodySmall),
      ],
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 16),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[const AiAvatar(), const SizedBox(width: 8)],
            Flexible(child: content),
          ],
        ),
      ),
    );
  }
}

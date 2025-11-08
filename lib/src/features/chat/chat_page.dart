import 'package:flutter/material.dart';
import '../../common/theme/app_theme.dart';
import '../../common/widgets/glass_container.dart';
import '../../common/widgets/glass_text_field.dart';
import '../../common/widgets/glass_button.dart';

/// Placeholder chat/message UI with future extensibility
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Text('Chat', style: AppTheme.displaySmall),
              ),
              // Messages List
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              'No messages yet',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Text(
                              'Start a conversation',
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _ChatBubble(message: message);
                        },
                      ),
              ),
              // Input Area
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: _messageController,
                        hintText: 'Type a message...',
                        maxLines: null,
                        prefixIcon: Icons.message_outlined,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    GlassButton(
                      label: 'Send',
                      icon: Icons.send,
                      onPressed: _messageController.text.trim().isNotEmpty
                          ? _sendMessage
                          : null,
                      height: 56,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentPrimary.withOpacity(0.3),
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: AppTheme.accentPrimary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
          ],
          Flexible(
            child: GlassContainer(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              borderRadius: AppTheme.glassBorderRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: AppTheme.bodyMedium),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTheme.bodySmall.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppTheme.spacingS),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentSecondary.withOpacity(0.3),
              child: Icon(
                Icons.person,
                size: 16,
                color: AppTheme.accentSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

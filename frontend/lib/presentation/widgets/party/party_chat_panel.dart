import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/watch_party/watch_party_state.dart';

class PartyChatPanel extends StatefulWidget {
  final List<PartyMessage> messages;
  final String? roomId;
  final int participantCount;
  final Function(String text) onSendMessage;
  final Function(String emoji) onSendReaction;

  const PartyChatPanel({
    super.key,
    required this.messages,
    this.roomId,
    this.participantCount = 1,
    required this.onSendMessage,
    required this.onSendReaction,
  });

  @override
  State<PartyChatPanel> createState() => _PartyChatPanelState();
}

class _PartyChatPanelState extends State<PartyChatPanel> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _quickEmojis = ['❤️', '😂', '😱', '🔥', '👏', '🎉', '🍿', '😮'];

  @override
  void didUpdateWidget(PartyChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _copyRoomLink(BuildContext context) {
    if (widget.roomId == null) return;
    final currentUrl = Uri.base.origin;
    final shareUrl = '$currentUrl/watch-party?room=${widget.roomId}';
    Clipboard.setData(ClipboardData(text: shareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép link mời: $shareUrl'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                const Text(
                  'Trò chuyện trực tiếp',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (widget.roomId != null)
                  InkWell(
                    onTap: () => _copyRoomLink(context),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Phòng: ${widget.roomId}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy_rounded, size: 12, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: widget.messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 36, color: AppColors.textMuted),
                        SizedBox(height: 8),
                        Text(
                          'Chưa có tin nhắn nào.\nHãy gửi lời chào đến mọi người!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) {
                      final msg = widget.messages[index];
                      return _buildMessageItem(msg);
                    },
                  ),
          ),

          // Quick Reaction Emoji Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _quickEmojis.map((emoji) {
                return InkWell(
                  onTap: () => widget.onSendReaction(emoji),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primaryLight, size: 20),
                  onPressed: _handleSend,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(PartyMessage msg) {
    final timeStr = DateFormat('HH:mm').format(msg.timestamp);

    if (msg.type == 'system') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msg.content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (msg.type == 'reaction') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text(msg.senderAvatar, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              msg.senderName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(msg.reactionEmoji ?? '❤️', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Text(timeStr, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: Text(msg.senderAvatar, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      msg.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    msg.content,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

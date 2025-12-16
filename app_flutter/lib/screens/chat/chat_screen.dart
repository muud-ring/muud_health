import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/chat/chat_message.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String title;
  final String myUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.title,
    required this.myUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  bool _sending = false;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool scrollToBottom = true}) async {
    try {
      final msgs = await ApiService.fetchMessages(widget.conversationId);
      if (!mounted) return;
      setState(() {
        _messages = msgs;
        _loading = false;
      });

      if (scrollToBottom) {
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load messages: $e")));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();

    // ✅ 1) Optimistic message (shows instantly)
    final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";
    final optimistic = ChatMessage(
      id: tempId,
      conversationId: widget.conversationId,
      senderId: widget.myUserId,
      text: text,
      imageUrl: null,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(optimistic);
    });

    _scrollToBottom();

    try {
      // ✅ 2) Send to backend
      await ApiService.sendMessage(
        conversationId: widget.conversationId,
        text: text,
      );

      // ✅ 3) Sync from backend (replace temp IDs with real ones)
      await _loadMessages(scrollToBottom: true);
    } catch (e) {
      // ❌ If send fails, remove optimistic message
      if (!mounted) return;

      setState(() {
        _messages.removeWhere((m) => m.id == tempId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Send failed: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        foregroundColor: kPrimaryPurple,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadMessages(scrollToBottom: false),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final m = _messages[index];
                        final isMe = m.senderId == widget.myUserId;

                        return _MessageBubble(text: m.text, isMe: isMe);
                      },
                    ),
                  ),
          ),

          // Composer
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: "Message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _sending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryPurple,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? kPrimaryPurple : kPrimaryPurple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

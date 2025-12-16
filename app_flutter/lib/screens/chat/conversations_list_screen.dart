import 'package:flutter/material.dart';
import 'package:app_flutter/services/api_service.dart';
import 'package:app_flutter/services/token_storage.dart';
import 'package:app_flutter/models/chat/conversation_preview.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  bool _loading = true;
  String? _error;
  List<ConversationPreview> _items = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final token = await TokenStorage.getToken();
      if (token == null) {
        setState(() {
          _loading = false;
          _error = "No token found. Please login again.";
        });
        return;
      }

      final list = await ApiService.getMyConversations(token);

      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Inbox",
          style: TextStyle(
            color: kPrimaryPurple,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: kPrimaryPurple),
      ),

      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              )
            : _items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      "No conversations yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 18),
                itemBuilder: (context, i) {
                  final c = _items[i];
                  final initial = c.otherUserName.isNotEmpty
                      ? c.otherUserName[0].toUpperCase()
                      : "U";

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: kPrimaryPurple.withOpacity(0.12),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: kPrimaryPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      c.otherUserName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      c.lastMessageText.isEmpty
                          ? "Say hi 👋"
                          : c.lastMessageText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Step B4: open chat screen using conversationId
                      // Navigator.push(...)
                    },
                  );
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/people/person_profile.dart';
import '../chat/chat_screen.dart';
import '../../models/chat/conversation.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);
const Color kLightPurple = Color(0xFFDAC9E8);

class PeopleProfileScreen extends StatefulWidget {
  final String personId;

  const PeopleProfileScreen({super.key, required this.personId});

  @override
  State<PeopleProfileScreen> createState() => _PeopleProfileScreenState();
}

class _PeopleProfileScreenState extends State<PeopleProfileScreen> {
  late Future<PersonProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.fetchPersonProfile(widget.personId);
  }

  void _retry() {
    setState(() {
      _profileFuture = ApiService.fetchPersonProfile(widget.personId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        foregroundColor: kPrimaryPurple,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<PersonProfile>(
        future: _profileFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError || !snap.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Failed to load profile"),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final p = snap.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: kLightPurple,
                  backgroundImage:
                      (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                      ? NetworkImage(p.avatarUrl!)
                      : null,
                  child: (p.avatarUrl == null || p.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 42, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryPurple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p.username != null && p.username!.isNotEmpty
                      ? "@${p.username}"
                      : "",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Text(
                  (p.bio ?? "").isEmpty ? "No bio yet." : p.bio!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87),
                ),
                const Spacer(),

                // We'll wire real chat in next step.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Create (or return existing) conversation between me + this person
                        final Conversation convo =
                            await ApiService.createConversation(
                              otherUserId: widget.personId,
                            );

                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: convo.id,
                              title: p.name,
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to start chat: $e")),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Message",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

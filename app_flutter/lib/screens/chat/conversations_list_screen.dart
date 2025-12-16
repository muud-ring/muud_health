import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class ConversationsListScreen extends StatelessWidget {
  const ConversationsListScreen({super.key});

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

      body: const Center(
        child: Text(
          "Inbox will show conversations here",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

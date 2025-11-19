import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _status = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProtectedData();
  }

  Future<void> _loadProtectedData() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      // No token → go back to login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final result = await ApiService.getProtectedData(token);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _status = 'Protected data: ${result['data'].toString()}';
      } else {
        _status = 'Error: ${result['message']}';
      }
    });
  }

  Future<void> _logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MUUD Health - Home'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_status, textAlign: TextAlign.center),
              ),
      ),
    );
  }
}

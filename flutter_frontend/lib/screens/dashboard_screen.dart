import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../services/api_service.dart';
import '../services/chat_socket_service.dart';
import 'chat_screen.dart';
import 'products_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.apiService,
    required this.session,
    required this.onLogout,
    required this.onProductCountChanged,
    super.key,
  });

  final ApiService apiService;
  final AuthSession session;
  final Future<void> Function() onLogout;
  final Future<void> Function(int count) onProductCountChanged;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ChatSocketService _chatSocketService = ChatSocketService();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _chatSocketService.disconnect();
    super.dispose();
  }

  Future<void> _logout() async {
    _chatSocketService.disconnect();
    await widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ChatScreen(
        session: widget.session,
        socketService: _chatSocketService,
      ),
      ProductsScreen(
        apiService: widget.apiService,
        session: widget.session,
        onProductCountChanged: widget.onProductCountChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoHome Chat'),
        backgroundColor: const Color(0xff2c3e50),
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${widget.session.username} (${widget.session.productCount})'),
            ),
          ),
          TextButton(
            onPressed: _logout,
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'models/auth_session.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';

void main() {
  runApp(const EcoHomeApp());
}

class EcoHomeApp extends StatefulWidget {
  const EcoHomeApp({super.key});

  @override
  State<EcoHomeApp> createState() => _EcoHomeAppState();
}

class _EcoHomeAppState extends State<EcoHomeApp> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();
  AuthSession? _session;
  bool _loadingSession = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await _sessionService.loadSession();

    setState(() {
      _session = session;
      _loadingSession = false;
    });
  }

  Future<void> _onLogin(AuthSession session) async {
    await _sessionService.saveSession(session);

    setState(() {
      _session = session;
    });
  }

  Future<void> _onLogout() async {
    await _sessionService.clearSession();

    setState(() {
      _session = null;
    });
  }

  Future<void> _updateProductCount(int count) async {
    final current = _session;
    if (current == null) return;

    await _sessionService.saveProductCount(count);

    setState(() {
      _session = AuthSession(
        token: current.token,
        username: current.username,
        userId: current.userId,
        productCount: count,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHome Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff27ae60)),
        scaffoldBackgroundColor: const Color(0xfff3f5f7),
        useMaterial3: true,
      ),
      home: _loadingSession
          ? const _LoadingSession()
          : _session == null
              ? LoginScreen(
                  apiService: _apiService,
                  onLogin: _onLogin,
                )
              : DashboardScreen(
                  apiService: _apiService,
                  session: _session!,
                  onLogout: _onLogout,
                  onProductCountChanged: _updateProductCount,
                ),
    );
  }
}

class _LoadingSession extends StatelessWidget {
  const _LoadingSession();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

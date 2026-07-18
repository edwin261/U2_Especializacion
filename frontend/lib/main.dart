import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

void main() {
  runApp(const EcoHomeApp());
}

class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.64:3001',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: apiBaseUrl,
  );
}

class AuthSession {
  const AuthSession({required this.token, required this.username});

  final String token;
  final String username;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.username,
    required this.text,
    this.createdAt,
  });

  final int? id;
  final String username;
  final String text;
  final DateTime? createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      username: (json['username'] ?? json['name'] ?? 'Usuario') as String,
      text: (json['text'] ?? '') as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _usernameKey = 'username';

  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(_usernameKey, session.username);
  }

  Future<AuthSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final username = prefs.getString(_usernameKey);

    if (token == null || token.isEmpty || username == null || username.isEmpty) {
      return null;
    }

    return AuthSession(token: token, username: username);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
  }
}

class AuthService {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/auth/login'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    final Map<String, dynamic> payload = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw Exception(payload['message'] ?? 'No fue posible iniciar sesión');
    }

    final token = payload['token'] as String?;
    final username = payload['username'] as String?;

    if (token == null || username == null) {
      throw Exception('La respuesta del backend no contiene token o username');
    }

    return AuthSession(token: token, username: username);
  }
}

class ChatService {
  ChatService();

  final ValueNotifier<List<ChatMessage>> messages =
      ValueNotifier<List<ChatMessage>>(<ChatMessage>[]);
  final ValueNotifier<String?> connectionError = ValueNotifier<String?>(null);

  io.Socket? _socket;

  void connect(String token) {
    disconnect();

    _socket = io.io(
      AppConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setAuth(<String, dynamic>{'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      connectionError.value = null;
    });

    _socket!.onConnectError((dynamic error) {
      connectionError.value = error.toString();
    });

    _socket!.onError((dynamic error) {
      connectionError.value = error.toString();
    });

    _socket!.on('chat-history', (dynamic data) {
      messages.value = _parseMessages(data);
    });

    _socket!.on('receive-message', (dynamic data) {
      final newMessage = ChatMessage.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
      final updated = List<ChatMessage>.from(messages.value)..add(newMessage);
      messages.value = updated;
    });

    _socket!.connect();
  }

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _socket?.emit('new-message', <String, dynamic>{'text': trimmed});
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    messages.dispose();
    connectionError.dispose();
  }

  List<ChatMessage> _parseMessages(dynamic data) {
    if (data is! List) {
      return <ChatMessage>[];
    }

    return data
        .map(
          (dynamic item) => ChatMessage.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}

// ─────────────────────────────────────────
// Catálogo – modelo, servicio y pantalla
// ─────────────────────────────────────────

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.creatorName,
  });

  final int id;
  final String name;
  final double price;
  final String creatorName;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      creatorName: (json['User']?['name'] ?? 'Desconocido') as String,
    );
  }
}

class ProductService {
  final ValueNotifier<int> productCount = ValueNotifier<int>(0);

  Future<void> loadProductCount(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/products/stats'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    productCount.value = body['products'] as int;
  }

  Future<Product> createProduct({
    required String token,
    required String name,
    required double price,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
      }),
    );

    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw Exception(body['message']);
    }

    // Actualiza el contador
    await loadProductCount(token);

    return Product.fromJson(
      jsonDecode(response.body),
    );
  }
  
  Future<List<Product>> getProducts(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/products'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 400) {
      try {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((e) => Product.fromJson(e))
            .toList();
      } catch (e) {
        throw Exception(
          'La respuesta del servidor no es JSON.\n'
          'Status: ${response.statusCode}\n'
          'Body:\n${response.body}',
        );
      }
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<int> getMyProductCount(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/products/stats'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 400) {
      throw Exception('No fue posible obtener las estadísticas');
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

    return body['products'] as int;
  }
}

class CreateProductScreen extends StatefulWidget {

  const CreateProductScreen({
    super.key,
    required this.session,
    required this.productService,
  });

  final AuthSession session;
  final ProductService productService;

  @override
  State<CreateProductScreen> createState() =>
      _CreateProductScreenState();
}

class _CreateProductScreenState
    extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      final product =
          await widget.productService.createProduct(
          token: widget.session.token,
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text),
        );
      if (!mounted) return;
      Navigator.pop(context, product);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo producto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                ),
                validator: (value) =>
                    value!.isEmpty
                        ? "Ingrese el nombre"
                        : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                        decimal: true),
                decoration: const InputDecoration(
                  labelText: "Precio",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese el precio";
                  }
                  if (double.tryParse(value) == null) {
                    return "Precio inválido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed:
                    _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: _saving
                    ? const CircularProgressIndicator()
                    : const Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({required this.session, super.key});

  final AuthSession session;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Product>> _productsFuture;
  final ProductService _service = ProductService();

  @override
  void initState() {
    super.initState();
    _productsFuture = _service.getProducts(widget.session.token);
  }

  Future<void> _newProduct() async {
    final Product? product =
        await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateProductScreen(
          session: widget.session,
          productService: _service,
        ),
      ),
    );

    if (product != null) {
      _retry();

      // Indica que el catálogo cambió
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  void _retry() {
    setState(() {
      _productsFuture = _service.getProducts(widget.session.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _newProduct,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Catálogo de productos'),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _retry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? <Product>[];

          if (products.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _retry(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                return _ProductCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Creado por: ${product.creatorName}",
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class EcoHomeApp extends StatelessWidget {
  const EcoHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHome Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155E63),
        ),
        useMaterial3: true,
      ),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  final TokenStorage _tokenStorage = TokenStorage();
  late Future<AuthSession?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _tokenStorage.readSession();
  }

  void _refreshSession() {
    setState(() {
      _sessionFuture = _tokenStorage.readSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSession?>(
      future: _sessionFuture,
      builder: (BuildContext context, AsyncSnapshot<AuthSession?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data;

        if (session == null) {
          return LoginScreen(
            authService: AuthService(),
            tokenStorage: _tokenStorage,
            onLoggedIn: _refreshSession,
          );
        }

        return ChatScreen(
          session: session,
          tokenStorage: _tokenStorage,
          onLoggedOut: _refreshSession,
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.authService,
    required this.tokenStorage,
    required this.onLoggedIn,
    super.key,
  });

  final AuthService authService;
  final TokenStorage tokenStorage;
  final VoidCallback onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final session = await widget.authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await widget.tokenStorage.saveSession(session);

      if (!mounted) {
        return;
      }

      widget.onLoggedIn();
    } catch (error) {
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'EcoHome Chat',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login con el backend existente y persistencia local del JWT.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                        if (_error != null) ...<Widget>[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Ingresar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.session,
    required this.tokenStorage,
    required this.onLoggedOut,
    super.key,
  });

  final AuthSession session;
  final TokenStorage tokenStorage;
  final VoidCallback onLoggedOut;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatService _chatService;
  late final ProductService _productService;
  late Future<int> _productCountFuture;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _chatService.connect(widget.session.token);

    _productService = ProductService();
    _productService.loadProductCount(widget.session.token);
    _productCountFuture =
      _productService.getMyProductCount(widget.session.token);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatService.dispose();
    _productService.productCount.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await widget.tokenStorage.clear();

    if (!mounted) {
      return;
    }

    widget.onLoggedOut();
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) {
      return;
    }

    _chatService.sendMessage(text);
    _messageController.clear();
  }

  Future<void> _openCatalog() async {
    final bool? changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogScreen(
          session: widget.session,
        ),
      ),
    );

    if (changed == true) {
      await _productService.loadProductCount(widget.session.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('EcoHome Chat'),
            ValueListenableBuilder<int>(
              valueListenable: _productService.productCount,
              builder: (context, count, child) {
                return Text(
                  '${widget.session.username} ($count)',
                  style: Theme.of(context).textTheme.labelMedium,
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _openCatalog,
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Catálogo',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ValueListenableBuilder<String?>(
              valueListenable: _chatService.connectionError,
              builder: (BuildContext context, String? error, Widget? child) {
                if (error == null) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Error de conexión: $error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: ValueListenableBuilder<List<ChatMessage>>(
                valueListenable: _chatService.messages,
                builder: (
                  BuildContext context,
                  List<ChatMessage> messages,
                  Widget? child,
                ) {
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('Sin mensajes aún. Envía el primero.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final message = messages[index];
                      final isCurrentUser =
                          message.username == widget.session.username;

                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  message.username,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(message.text),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _sendMessage,
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
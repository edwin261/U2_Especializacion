# EcoHome Flutter Frontend

Frontend Flutter equivalente al frontend React actual. Consume el backend Express en `http://localhost:3001`.

## Funcionalidades

- Login con `POST /api/auth/login`.
- Persistencia de sesion con `SharedPreferences`.
- Dashboard autenticado con modulos de Chat y Productos.
- Chat en tiempo real con Socket.IO:
  - `chat-history`
  - `new-message`
  - `receive-message`
- Gestion de productos:
  - listar productos
  - crear productos
  - editar productos propios
  - eliminar productos propios
  - mostrar creador desde `User.name`
- Navbar/AppBar con formato `NombreUsuario (N)`.

## Preparacion

Este entorno no tiene Flutter instalado, por eso no se generaron carpetas nativas como `android/`, `ios/` o `web/`.

En una maquina con Flutter instalado:

```bash
cd flutter_frontend
flutter create .
flutter pub get
flutter run
```

Para Android emulator, cambia en `lib/config.dart`:

```dart
static const String apiBaseUrl = 'http://10.0.2.2:3001/api';
static const String socketUrl = 'http://10.0.2.2:3001';
```

Para navegador o desktop local, puedes dejar:

```dart
static const String apiBaseUrl = 'http://localhost:3001/api';
static const String socketUrl = 'http://localhost:3001';
```

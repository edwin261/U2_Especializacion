# Flutter Mobile Client

Cliente Flutter para consumir el backend existente sin cambiar endpoints:

- `POST /api/auth/login`
- Socket.IO con JWT enviado en `auth.token`

## Requisitos

- Flutter SDK instalado localmente
- Backend ejecutándose, por ejemplo en `http://localhost:3001`

## Configuración de URL

La app admite `dart-define` para apuntar al backend:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3001 \
  --dart-define=SOCKET_URL=http://10.0.2.2:3001
```

Notas:

- En Android Emulator usa `10.0.2.2` para acceder al host local.
- En iOS Simulator normalmente puedes usar `http://localhost:3001`.

## Si faltan carpetas nativas

Como este workspace no tenía un proyecto Flutter generado, si necesitas crear las carpetas de plataforma ejecuta:

```bash
flutter create .
```

Luego instala dependencias:

```bash
flutter pub get
```

## Flujo soportado

1. Login contra el backend existente.
2. Persistencia local de JWT y nombre de usuario.
3. Conexión Socket.IO autenticada con ese JWT.
4. Recepción de historial `chat-history`.
5. Envío de mensajes mediante `new-message`.
6. Recepción de nuevos mensajes por `receive-message`.
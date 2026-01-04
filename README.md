# MinGO Flutter - Frontend Corregido v1.1.0

## 📱 Descripción

Frontend Flutter de MinGO, una aplicación de enseñanza de lengua de señas ecuatoriana.
Esta versión está **100% alineada con la API NestJS v1.1.0**.

## ✅ Cambios Principales (Correcciones)

### 🔴 Corregido: Roles de Usuario
```dart
// ANTES (incorrecto)
enum UserRole { parent, teacher, admin }

// AHORA (correcto - alineado con API)
enum UserRole {
  padre('PADRE'),
  docente('DOCENTE'),
  admin('ADMIN');
}
```

### 🔴 Corregido: Campo `name` vs `fullName`
- API espera `name`, no `fullName`
- Actualizado en User entity, UserModel y RegisterParams

### 🔴 Corregido: Auth usa API NestJS
- **ANTES**: Usaba Supabase Auth directamente
- **AHORA**: Usa la API NestJS con JWT propio
- Endpoints: `/auth/register`, `/auth/login`, `/auth/profile`, etc.

### 🔴 Agregado: Verificación de Email
Nuevas pantallas:
- `EmailVerificationPendingPage` - Después del registro
- `VerifyEmailPage` - Al hacer clic en el enlace
- `ForgotPasswordPage` - Solicitar reset
- `ResetPasswordPage` - Cambiar contraseña

### 🔴 Agregado: Campo `emailVerified`
- La entidad User ahora incluye `emailVerified`
- El flujo de auth verifica si el email está verificado

## 🏗️ Arquitectura

```
lib/
├── main.dart
├── app.dart
├── injection_container.dart
│
├── core/
│   ├── config/          # app_config, routes, theme
│   ├── constants/       # colors, typography, dimensions, endpoints
│   ├── errors/          # failures, exceptions
│   ├── network/         # api_client, network_info
│   ├── utils/           # validators
│   └── widgets/         # (próximamente)
│
├── features/
│   ├── auth/            # ✅ COMPLETO
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   │
│   ├── content/         # ⚠️ Estructura lista, implementar
│   ├── children/        # ⚠️ Estructura lista, implementar
│   ├── progress/        # ⚠️ Estructura lista, implementar
│   ├── activities/      # 🔜 Pendiente
│   └── classes/         # 🔜 Pendiente
│
└── shared/              # Código compartido
```

## 📦 Dependencias

```yaml
# State Management
flutter_bloc: ^8.1.3
equatable: ^2.0.5
get_it: ^7.6.4

# Network
dio: ^5.4.0
connectivity_plus: ^5.0.2

# Storage
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0

# Utils
dartz: ^0.10.1
intl: ^0.19.0
```

## 🚀 Configuración

### 1. Configurar URL de la API

En `lib/core/config/app_config.dart`:

```dart
case Environment.dev:
  _instance = const AppConfig._(
    apiBaseUrl: 'http://10.0.2.2:3000', // Para emulador Android
    // O tu IP local: 'http://192.168.x.x:3000'
  );
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Ejecutar

```bash
flutter run
```

## 🔐 Flujo de Autenticación

```
┌─────────────────────────────────────────────────────────────┐
│                         SPLASH                              │
│                    Verifica sesión                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
          ┌────────────────┴────────────────┐
          │                                 │
          ▼                                 ▼
   ┌─────────────┐                 ┌─────────────────┐
   │   LOGIN     │                 │      HOME       │
   │             │                 │  (autenticado)  │
   └──────┬──────┘                 └─────────────────┘
          │
          ├─────────────────────────────┐
          │                             │
          ▼                             ▼
   ┌─────────────┐              ┌──────────────────┐
   │  REGISTER   │              │ FORGOT PASSWORD  │
   └──────┬──────┘              └────────┬─────────┘
          │                              │
          ▼                              ▼
┌─────────────────────┐         ┌──────────────────┐
│ EMAIL VERIFICATION  │         │ RESET PASSWORD   │
│     PENDING         │         │   (con token)    │
└─────────────────────┘         └──────────────────┘
```

## 📂 Archivos Principales

| Archivo | Descripción |
|---------|-------------|
| `lib/features/auth/domain/entities/user.dart` | Entidad User con roles corregidos |
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | Comunicación con API |
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | BLoC de autenticación |
| `lib/core/network/api_client.dart` | Cliente HTTP con JWT |
| `lib/core/constants/api_endpoints.dart` | Endpoints de la API |

## 📊 Estado del Proyecto

| Módulo | Estado | Descripción |
|--------|--------|-------------|
| Core | ✅ 100% | Config, constantes, network, errores |
| Auth | ✅ 100% | Login, registro, verificación, reset |
| Content | ⚠️ 60% | Estructura lista, pages placeholder |
| Children | ⚠️ 40% | Estructura lista, implementar |
| Progress | ⚠️ 40% | Estructura lista, implementar |
| Activities | 🔜 0% | Pendiente |
| Classes | 🔜 0% | Pendiente |

## 🔜 Próximos Pasos

1. **Completar Content**: Implementar datasource y páginas
2. **Completar Children**: CRUD de perfiles de hijos
3. **Completar Progress**: Tracking de progreso
4. **Fase 4**: Actividades interactivas
5. **Fase 5**: Sistema de clases (docentes)

## 📝 Notas

- Esta versión usa **solo la API NestJS** para autenticación
- Los tokens JWT se guardan en `FlutterSecureStorage`
- El `ApiClient` maneja automáticamente el refresh token
- Compatible con iOS, Android y Web

---

**MinGO** - Aprende lengua de señas jugando 🤟

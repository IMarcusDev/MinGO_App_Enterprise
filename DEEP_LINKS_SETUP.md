# Configuración de Deep Links - MinGO

Esta guía documenta la configuración de deep links implementada en la aplicación MinGO para manejar enlaces de verificación de email y reset de contraseña.

## ✅ Configuración Completada

### 1. Dependencias

Se agregó `uni_links: ^0.5.1` al archivo `pubspec.yaml`.

```bash
flutter pub get
```

### 2. Configuración Android

**Archivo:** `android/app/src/main/AndroidManifest.xml`

Se agregaron dos intent-filters para manejar:
- `mingo://verify-email?token=xxx`
- `mingo://reset-password?token=xxx`

```xml
<!-- Deep Links para MinGO -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="mingo"
        android:host="verify-email" />
</intent-filter>

<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="mingo"
        android:host="reset-password" />
</intent-filter>
```

### 3. Configuración iOS

**Archivo:** `ios/Runner/Info.plist`

Se agregó el esquema de URL para iOS:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.example.mingo</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>mingo</string>
        </array>
    </dict>
</array>
```

### 4. Servicio de Deep Links

**Archivo:** `lib/core/services/deep_link_service.dart`

Se creó un servicio que:
- Escucha deep links cuando la app está cerrada (`getInitialUri`)
- Escucha deep links cuando la app está abierta (`uriLinkStream`)
- Maneja automáticamente la verificación de email
- Navega a la pantalla de reset de contraseña con el token

### 5. Inyección de Dependencias

**Archivo:** `lib/injection_container.dart`

Se registró el servicio en GetIt:

```dart
sl.registerLazySingleton<DeepLinkService>(
  () => DeepLinkService(sl()),
);
```

### 6. Inicialización en la App

**Archivo:** `lib/app.dart`

Se modificó `MingoApp` para inicializar el servicio de deep links:

```dart
class _MingoAppState extends State<MingoApp> {
  late final DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    _deepLinkService = sl<DeepLinkService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _deepLinkService.initDeepLinks(context);
      }
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }
}
```

### 7. Dependencias Android (MediaPipe)

**Archivo:** `android/app/build.gradle.kts`

Se agregó la dependencia de MediaPipe para hand tracking:

```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.mediapipe:tasks-vision:0.10.14")
}
```

## 📱 Flujos de Usuario

### Verificación de Email

1. Usuario se registra en la app
2. Recibe email con link: `mingo://verify-email?token=abc123`
3. Usuario toca el link en su cliente de email
4. Android/iOS abre la app MinGO automáticamente
5. La app:
   - Muestra diálogo de carga
   - Llama a `POST /api/v1/auth/verify-email` con el token
   - Muestra mensaje de éxito
   - Navega al login después de 2 segundos

### Reset de Contraseña

1. Usuario solicita reset desde la app (ForgotPasswordPage)
2. Recibe email con link: `mingo://reset-password?token=xyz789`
3. Usuario toca el link
4. La app abre `ResetPasswordPage` con el token
5. Usuario ingresa nueva contraseña
6. La app llama a `POST /api/v1/auth/reset-password`

## 🧪 Testing

### Probar en Android

```bash
# Método 1: Usando adb
adb shell am start -W -a android.intent.action.VIEW \
  -d "mingo://verify-email?token=test123" \
  com.example.mingo_mobile_app_enterprise

# Método 2: Usando terminal
adb shell am start -a android.intent.action.VIEW \
  -d "mingo://reset-password?token=test456" \
  com.example.mingo_mobile_app_enterprise
```

### Probar en iOS

```bash
# En simulador
xcrun simctl openurl booted "mingo://verify-email?token=test123"

# Para reset de password
xcrun simctl openurl booted "mingo://reset-password?token=test456"
```

### Probar desde Email Real

1. Configura el backend con `FRONTEND_URL="mingo://"`
2. Regístrate con tu email real desde la app
3. Abre el email en tu dispositivo móvil
4. Toca el link de verificación
5. La app debería abrirse automáticamente

## 🔧 Configuración del Backend

Actualiza la variable de entorno en Render:

```
FRONTEND_URL="mingo://"
```

Esto generará URLs como:
- `mingo://verify-email?token=abc123`
- `mingo://reset-password?token=xyz789`

## 🛡️ Seguridad

- Los tokens de verificación expiran en 24 horas
- Los tokens de reset expiran en 1 hora
- Los tokens son de un solo uso
- Si el token es inválido, la API retorna error 400

## 🔍 Troubleshooting

### Android: La app no se abre

1. Verifica que el intent-filter esté en AndroidManifest.xml
2. Revisa los logs: `adb logcat | grep mingo`
3. Asegúrate que el esquema coincida: `mingo://`
4. Reinstala la app completamente

### iOS: La app no se abre

1. Verifica Info.plist
2. Reinstala la app completamente
3. Revisa los logs de Xcode
4. Asegúrate de tener el simulador correcto seleccionado

### El token no se captura

1. Verifica que estés parseando: `uri.queryParameters['token']`
2. Asegúrate de inicializar el listener con `addPostFrameCallback`
3. Revisa los logs de consola: `debugPrint('Deep link received: $uri')`

### Build errors en Android

Si obtienes errores de MediaPipe:
1. Ejecuta `flutter clean`
2. Ejecuta `flutter pub get`
3. Reconstruye: `flutter run`

## 📝 Archivos Modificados

- ✅ `pubspec.yaml` - Dependencia uni_links
- ✅ `android/app/src/main/AndroidManifest.xml` - Intent filters
- ✅ `android/app/build.gradle.kts` - MediaPipe dependency
- ✅ `ios/Runner/Info.plist` - URL schemes
- ✅ `lib/core/services/deep_link_service.dart` - Servicio nuevo
- ✅ `lib/injection_container.dart` - Registro del servicio
- ✅ `lib/app.dart` - Inicialización del servicio

## 🚀 Próximos Pasos

1. Ejecutar `flutter pub get`
2. Probar los deep links en dispositivos reales
3. Configurar el backend con `FRONTEND_URL="mingo://"`
4. Realizar pruebas end-to-end completas

## 📚 Recursos

- [uni_links package](https://pub.dev/packages/uni_links)
- [Android Deep Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)

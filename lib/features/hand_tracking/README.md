# Configuración de MediaPipe Hand Tracking

## Descripción
Este módulo implementa detección de manos en tiempo real usando MediaPipe Tasks Vision para reconocimiento de Lengua de Señas Ecuatoriana (LSEC).

## Requisitos

### Android
- minSdkVersion: 24
- targetSdkVersion: 34
- Cámara frontal/trasera

### iOS
- iOS 12.0+
- Permisos de cámara

## Instalación

### 1. Dependencias Android

Agregar en `android/app/build.gradle`:

```gradle
dependencies {
    // MediaPipe Tasks Vision
    implementation 'com.google.mediapipe:tasks-vision:0.10.9'
}
```

### 2. Modelo de MediaPipe

Descargar el modelo `hand_landmarker.task` desde:
https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task

Colocarlo en:
```
android/app/src/main/assets/hand_landmarker.task
```

### 3. Permisos Android

En `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

### 4. Registrar Plugin

En `android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
import com.mingo.hand_tracking.HandTrackingPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(HandTrackingPlugin())
    }
}
```

### 5. Dependencias Flutter

En `pubspec.yaml`:

```yaml
dependencies:
  camera: ^0.10.5+9
  permission_handler: ^11.1.0
```

## Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Layer                         │
├─────────────────────────────────────────────────────────┤
│  HandTrackingBloc         SignComparisonService          │
│         │                         │                      │
│         └─────────┬───────────────┘                      │
│                   │                                      │
│         HandTrackingService (Platform Channel)           │
├─────────────────────────────────────────────────────────┤
│                  Native Layer                            │
├─────────────────────────────────────────────────────────┤
│  Android: HandTrackingPlugin.kt                          │
│  iOS: HandTrackingPlugin.swift (TODO)                    │
│         │                                                │
│    MediaPipe HandLandmarker                              │
└─────────────────────────────────────────────────────────┘
```

## Uso

### Inicializar

```dart
context.read<HandTrackingBloc>().add(
  const InitializeHandTrackingEvent(
    maxHands: 2,
    minConfidence: 0.5,
  ),
);
```

### Iniciar tracking

```dart
context.read<HandTrackingBloc>().add(const StartTrackingEvent());
```

### Escuchar frames

```dart
BlocBuilder<HandTrackingBloc, HandTrackingState>(
  builder: (context, state) {
    if (state.currentFrame?.hasHands == true) {
      // Dibujar landmarks
    }
  },
)
```

### Comparar con seña

```dart
context.read<HandTrackingBloc>().add(
  SetTargetSignEvent(SignTemplates.getById('hola')),
);

// Escuchar resultado
if (state.matchResult?.isMatch == true) {
  // ¡Seña correcta!
}
```

## Landmarks de la Mano (21 puntos)

```
        8   12  16  20        <- Puntas de dedos
        |   |   |   |
    7   11  15  19  |
    |   |   |   |   |
    6   10  14  18  |
    |   |   |   |   |
    5---9---13--17--+         <- Nudillos (MCP)
         \         |
          4       |           <- Pulgar
           \     |
            3   |
             \ |
              2
              |
              1
              |
              0               <- Muñeca
```

### Índices:
- 0: Muñeca
- 1-4: Pulgar (CMC, MCP, IP, TIP)
- 5-8: Índice (MCP, PIP, DIP, TIP)
- 9-12: Medio
- 13-16: Anular
- 17-20: Meñique

## Plantillas de Señas

Las plantillas definen:
- **fingerStates**: Estado de cada dedo (extendido, cerrado, doblado)
- **orientation**: Orientación de la palma
- **constraints**: Restricciones adicionales (dedos tocándose, etc.)

Ejemplo:

```dart
SignTemplate(
  id: 'letra_v',
  name: 'V',
  poses: [
    HandPoseTemplate(
      fingerStates: [
        FingerState(finger: Finger.thumb, position: FingerPosition.closed),
        FingerState(finger: Finger.index, position: FingerPosition.extended),
        FingerState(finger: Finger.middle, position: FingerPosition.extended),
        FingerState(finger: Finger.ring, position: FingerPosition.closed),
        FingerState(finger: Finger.pinky, position: FingerPosition.closed),
      ],
      orientation: HandOrientation.palmForward,
    ),
  ],
);
```

## Modo Simulación

Para desarrollo sin cámara:

```dart
// Activar en SignPracticePage
_simulationMode = true;

// Tocar y arrastrar en pantalla para simular landmarks
```

## Próximos Pasos

1. [ ] Implementar plugin iOS (Swift)
2. [ ] Agregar más plantillas LSEC
3. [ ] Entrenar modelo custom para LSEC
4. [ ] Detección de señas dinámicas (movimiento)
5. [ ] Feedback háptico
6. [ ] Modo offline con modelo descargado

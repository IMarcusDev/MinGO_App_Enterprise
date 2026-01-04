import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/hand_tracking_service.dart';
import '../../data/datasources/sign_comparison_service.dart';
import '../../domain/entities/hand_landmark_entities.dart';
import '../../domain/entities/sign_template_entities.dart';

// ============================================
// Events
// ============================================

abstract class HandTrackingEvent extends Equatable {
  const HandTrackingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeHandTrackingEvent extends HandTrackingEvent {
  final int maxHands;
  final double minConfidence;

  const InitializeHandTrackingEvent({
    this.maxHands = 2,
    this.minConfidence = 0.5,
  });

  @override
  List<Object?> get props => [maxHands, minConfidence];
}

class StartTrackingEvent extends HandTrackingEvent {
  const StartTrackingEvent();
}

class StopTrackingEvent extends HandTrackingEvent {
  const StopTrackingEvent();
}

class FrameReceivedEvent extends HandTrackingEvent {
  final HandTrackingFrame frame;
  const FrameReceivedEvent(this.frame);

  @override
  List<Object?> get props => [frame];
}

class SetTargetSignEvent extends HandTrackingEvent {
  final SignTemplate sign;
  const SetTargetSignEvent(this.sign);

  @override
  List<Object?> get props => [sign];
}

class ClearTargetSignEvent extends HandTrackingEvent {
  const ClearTargetSignEvent();
}

class StartPracticeSessionEvent extends HandTrackingEvent {
  final SignTemplate sign;
  const StartPracticeSessionEvent(this.sign);

  @override
  List<Object?> get props => [sign];
}

class EndPracticeSessionEvent extends HandTrackingEvent {
  const EndPracticeSessionEvent();
}

class RecordAttemptEvent extends HandTrackingEvent {
  final SignMatchResult result;
  const RecordAttemptEvent(this.result);

  @override
  List<Object?> get props => [result];
}

class DisposeHandTrackingEvent extends HandTrackingEvent {
  const DisposeHandTrackingEvent();
}

// ============================================
// State
// ============================================

enum HandTrackingStatus {
  initial,
  initializing,
  ready,
  tracking,
  error,
  disposed,
}

class HandTrackingState extends Equatable {
  final HandTrackingStatus status;
  final HandTrackingFrame? currentFrame;
  final SignTemplate? targetSign;
  final SignMatchResult? matchResult;
  final BasicGesture? detectedGesture;
  final PracticeSession? currentSession;
  final String? errorMessage;
  final bool isMediaPipeAvailable;
  final double fps;

  const HandTrackingState({
    this.status = HandTrackingStatus.initial,
    this.currentFrame,
    this.targetSign,
    this.matchResult,
    this.detectedGesture,
    this.currentSession,
    this.errorMessage,
    this.isMediaPipeAvailable = false,
    this.fps = 0,
  });

  bool get isTracking => status == HandTrackingStatus.tracking;
  bool get hasHands => currentFrame?.hasHands ?? false;
  bool get hasTwoHands => currentFrame?.hasTwoHands ?? false;
  bool get isMatch => matchResult?.isMatch ?? false;
  int get matchPercent => matchResult?.scorePercent ?? 0;

  HandTrackingState copyWith({
    HandTrackingStatus? status,
    HandTrackingFrame? currentFrame,
    SignTemplate? targetSign,
    SignMatchResult? matchResult,
    BasicGesture? detectedGesture,
    PracticeSession? currentSession,
    String? errorMessage,
    bool? isMediaPipeAvailable,
    double? fps,
  }) {
    return HandTrackingState(
      status: status ?? this.status,
      currentFrame: currentFrame ?? this.currentFrame,
      targetSign: targetSign,
      matchResult: matchResult,
      detectedGesture: detectedGesture ?? this.detectedGesture,
      currentSession: currentSession ?? this.currentSession,
      errorMessage: errorMessage,
      isMediaPipeAvailable: isMediaPipeAvailable ?? this.isMediaPipeAvailable,
      fps: fps ?? this.fps,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentFrame,
        targetSign,
        matchResult,
        detectedGesture,
        currentSession,
        errorMessage,
        isMediaPipeAvailable,
        fps,
      ];
}

// ============================================
// BLoC
// ============================================

class HandTrackingBloc extends Bloc<HandTrackingEvent, HandTrackingState> {
  final HandTrackingService _trackingService;
  final SignComparisonService _comparisonService;

  StreamSubscription? _frameSubscription;
  DateTime? _lastFrameTime;
  int _frameCount = 0;
  Timer? _fpsTimer;
  
  // Para detectar cuando se mantiene una pose
  DateTime? _poseStartTime;
  SignMatchResult? _lastMatchResult;
  static const Duration _holdDuration = Duration(milliseconds: 1000);

  HandTrackingBloc({
    HandTrackingService? trackingService,
    SignComparisonService? comparisonService,
  })  : _trackingService = trackingService ?? HandTrackingService.instance,
        _comparisonService = comparisonService ?? SignComparisonService(),
        super(const HandTrackingState()) {
    on<InitializeHandTrackingEvent>(_onInitialize);
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<FrameReceivedEvent>(_onFrameReceived);
    on<SetTargetSignEvent>(_onSetTargetSign);
    on<ClearTargetSignEvent>(_onClearTargetSign);
    on<StartPracticeSessionEvent>(_onStartPracticeSession);
    on<EndPracticeSessionEvent>(_onEndPracticeSession);
    on<RecordAttemptEvent>(_onRecordAttempt);
    on<DisposeHandTrackingEvent>(_onDispose);
  }

  Future<void> _onInitialize(
    InitializeHandTrackingEvent event,
    Emitter<HandTrackingState> emit,
  ) async {
    emit(state.copyWith(status: HandTrackingStatus.initializing));

    try {
      // Verificar disponibilidad
      final isAvailable = await HandTrackingService.isAvailable();
      
      if (!isAvailable) {
        // MediaPipe no disponible, usar modo simulación
        emit(state.copyWith(
          status: HandTrackingStatus.ready,
          isMediaPipeAvailable: false,
        ));
        return;
      }

      // Inicializar MediaPipe
      final initialized = await _trackingService.initialize(
        maxHands: event.maxHands,
        minDetectionConfidence: event.minConfidence,
        minTrackingConfidence: event.minConfidence,
      );

      if (initialized) {
        emit(state.copyWith(
          status: HandTrackingStatus.ready,
          isMediaPipeAvailable: true,
        ));
      } else {
        emit(state.copyWith(
          status: HandTrackingStatus.error,
          errorMessage: 'No se pudo inicializar el hand tracking',
          isMediaPipeAvailable: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HandTrackingStatus.error,
        errorMessage: e.toString(),
        isMediaPipeAvailable: false,
      ));
    }
  }

  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<HandTrackingState> emit,
  ) async {
    if (state.status != HandTrackingStatus.ready &&
        state.status != HandTrackingStatus.tracking) {
      return;
    }

    try {
      if (state.isMediaPipeAvailable) {
        final started = await _trackingService.startTracking();
        if (!started) {
          emit(state.copyWith(
            status: HandTrackingStatus.error,
            errorMessage: 'No se pudo iniciar el tracking',
          ));
          return;
        }

        // Escuchar frames
        _frameSubscription = _trackingService.frameStream.listen(
          (frame) => add(FrameReceivedEvent(frame)),
        );
      }

      // Iniciar contador de FPS
      _startFpsCounter();

      emit(state.copyWith(status: HandTrackingStatus.tracking));
    } catch (e) {
      emit(state.copyWith(
        status: HandTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStopTracking(
    StopTrackingEvent event,
    Emitter<HandTrackingState> emit,
  ) async {
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    _fpsTimer?.cancel();
    _fpsTimer = null;

    if (state.isMediaPipeAvailable) {
      await _trackingService.stopTracking();
    }

    emit(state.copyWith(
      status: HandTrackingStatus.ready,
      currentFrame: null,
      matchResult: null,
      fps: 0,
    ));
  }

  void _onFrameReceived(
    FrameReceivedEvent event,
    Emitter<HandTrackingState> emit,
  ) {
    _frameCount++;
    final frame = event.frame;

    // Detectar gesto básico si no hay seña objetivo
    BasicGesture? gesture;
    SignMatchResult? matchResult;

    if (frame.hasHands) {
      final primaryHand = frame.rightHand ?? frame.leftHand;
      
      if (primaryHand != null) {
        // Si hay seña objetivo, comparar
        if (state.targetSign != null) {
          matchResult = _comparisonService.compareWithTemplate(
            primaryHand,
            state.targetSign!,
          );
          
          // Verificar si se mantiene la pose
          _checkPoseHold(matchResult, emit);
        } else {
          // Detectar gesto básico
          gesture = _comparisonService.detectBasicGesture(primaryHand);
        }
      }
    }

    emit(state.copyWith(
      currentFrame: frame,
      matchResult: matchResult,
      detectedGesture: gesture,
    ));
  }

  void _checkPoseHold(SignMatchResult result, Emitter<HandTrackingState> emit) {
    if (result.isMatch) {
      if (_lastMatchResult?.isMatch != true) {
        // Acaba de coincidir, iniciar timer
        _poseStartTime = DateTime.now();
      } else if (_poseStartTime != null) {
        // Ya estaba coincidiendo, verificar duración
        final elapsed = DateTime.now().difference(_poseStartTime!);
        if (elapsed >= _holdDuration && state.currentSession != null) {
          // ¡Pose mantenida exitosamente!
          add(RecordAttemptEvent(result));
          _poseStartTime = null;
        }
      }
    } else {
      _poseStartTime = null;
    }
    
    _lastMatchResult = result;
  }

  void _onSetTargetSign(
    SetTargetSignEvent event,
    Emitter<HandTrackingState> emit,
  ) {
    emit(state.copyWith(
      targetSign: event.sign,
      matchResult: null,
    ));
  }

  void _onClearTargetSign(
    ClearTargetSignEvent event,
    Emitter<HandTrackingState> emit,
  ) {
    emit(state.copyWith(
      targetSign: null,
      matchResult: null,
    ));
  }

  void _onStartPracticeSession(
    StartPracticeSessionEvent event,
    Emitter<HandTrackingState> emit,
  ) {
    final session = PracticeSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      signId: event.sign.id,
      startTime: DateTime.now(),
    );

    emit(state.copyWith(
      currentSession: session,
      targetSign: event.sign,
      matchResult: null,
    ));
  }

  void _onEndPracticeSession(
    EndPracticeSessionEvent event,
    Emitter<HandTrackingState> emit,
  ) {
    if (state.currentSession == null) return;

    // Aquí podrías guardar la sesión en el repositorio
    
    emit(state.copyWith(
      currentSession: null,
      targetSign: null,
      matchResult: null,
    ));
  }

  void _onRecordAttempt(
    RecordAttemptEvent event,
    Emitter<HandTrackingState> emit,
  ) {
    if (state.currentSession == null) return;

    final attempt = PracticeAttempt(
      attemptNumber: state.currentSession!.attempts.length + 1,
      timestamp: DateTime.now(),
      score: event.result.overallScore,
      feedback: event.result.feedback,
      holdTimeMs: _holdDuration.inMilliseconds,
    );

    final updatedAttempts = [...state.currentSession!.attempts, attempt];
    final updatedSession = PracticeSession(
      id: state.currentSession!.id,
      signId: state.currentSession!.signId,
      startTime: state.currentSession!.startTime,
      attempts: updatedAttempts,
    );

    emit(state.copyWith(currentSession: updatedSession));
  }

  Future<void> _onDispose(
    DisposeHandTrackingEvent event,
    Emitter<HandTrackingState> emit,
  ) async {
    await _frameSubscription?.cancel();
    _fpsTimer?.cancel();
    
    if (state.isMediaPipeAvailable) {
      await _trackingService.dispose();
    }

    emit(state.copyWith(status: HandTrackingStatus.disposed));
  }

  void _startFpsCounter() {
    _frameCount = 0;
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // No podemos emitir desde un timer, usamos add
      // El FPS se actualiza en el siguiente frame
    });
  }

  @override
  Future<void> close() async {
    await _frameSubscription?.cancel();
    _fpsTimer?.cancel();
    return super.close();
  }
}

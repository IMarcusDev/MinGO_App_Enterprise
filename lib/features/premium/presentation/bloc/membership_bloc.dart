import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/membership_entities.dart';

// ============================================
// Events
// ============================================

abstract class MembershipEvent extends Equatable {
  const MembershipEvent();

  @override
  List<Object?> get props => [];
}

class LoadMembershipEvent extends MembershipEvent {
  const LoadMembershipEvent();
}

class SelectPlanEvent extends MembershipEvent {
  final MembershipPlan plan;
  const SelectPlanEvent(this.plan);

  @override
  List<Object?> get props => [plan];
}

class SelectPaymentMethodEvent extends MembershipEvent {
  final PaymentMethod method;
  const SelectPaymentMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

class ProcessPaymentEvent extends MembershipEvent {
  const ProcessPaymentEvent();
}

class CancelMembershipEvent extends MembershipEvent {
  const CancelMembershipEvent();
}

class RestorePurchaseEvent extends MembershipEvent {
  const RestorePurchaseEvent();
}

// ============================================
// State
// ============================================

enum MembershipStateStatus {
  initial,
  loading,
  loaded,
  processing,
  success,
  error,
}

class MembershipState extends Equatable {
  final MembershipStateStatus status;
  final Membership? currentMembership;
  final MembershipPlan selectedPlan;
  final PaymentMethod selectedPaymentMethod;
  final String? errorMessage;
  final PaymentResult? lastPaymentResult;

  const MembershipState({
    this.status = MembershipStateStatus.initial,
    this.currentMembership,
    this.selectedPlan = MembershipPlan.monthly,
    this.selectedPaymentMethod = PaymentMethod.stripe,
    this.errorMessage,
    this.lastPaymentResult,
  });

  bool get isPremium => currentMembership?.isActive ?? false;

  MembershipState copyWith({
    MembershipStateStatus? status,
    Membership? currentMembership,
    MembershipPlan? selectedPlan,
    PaymentMethod? selectedPaymentMethod,
    String? errorMessage,
    PaymentResult? lastPaymentResult,
  }) {
    return MembershipState(
      status: status ?? this.status,
      currentMembership: currentMembership ?? this.currentMembership,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      errorMessage: errorMessage,
      lastPaymentResult: lastPaymentResult ?? this.lastPaymentResult,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentMembership,
        selectedPlan,
        selectedPaymentMethod,
        errorMessage,
        lastPaymentResult,
      ];
}

// ============================================
// BLoC
// ============================================

class MembershipBloc extends Bloc<MembershipEvent, MembershipState> {
  final SharedPreferences _prefs;

  static const String _membershipKey = 'membership_data';
  static const String _isPremiumKey = 'is_premium';

  MembershipBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const MembershipState()) {
    on<LoadMembershipEvent>(_onLoadMembership);
    on<SelectPlanEvent>(_onSelectPlan);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<ProcessPaymentEvent>(_onProcessPayment);
    on<CancelMembershipEvent>(_onCancelMembership);
    on<RestorePurchaseEvent>(_onRestorePurchase);
  }

  Future<void> _onLoadMembership(
    LoadMembershipEvent event,
    Emitter<MembershipState> emit,
  ) async {
    emit(state.copyWith(status: MembershipStateStatus.loading));

    try {
      // Cargar membresía guardada localmente
      final membershipJson = _prefs.getString(_membershipKey);
      Membership? membership;

      if (membershipJson != null) {
        // Decodificar membresía guardada
        // En producción, esto vendría del servidor
        final isPremium = _prefs.getBool(_isPremiumKey) ?? false;
        
        if (isPremium) {
          membership = Membership(
            id: 'local_membership',
            userId: 'current_user',
            plan: MembershipPlan.monthly,
            status: MembershipStatus.active,
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 15)),
          );
        }
      }

      emit(state.copyWith(
        status: MembershipStateStatus.loaded,
        currentMembership: membership,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MembershipStateStatus.error,
        errorMessage: 'Error al cargar membresía: $e',
      ));
    }
  }

  void _onSelectPlan(
    SelectPlanEvent event,
    Emitter<MembershipState> emit,
  ) {
    emit(state.copyWith(selectedPlan: event.plan));
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<MembershipState> emit,
  ) {
    emit(state.copyWith(selectedPaymentMethod: event.method));
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<MembershipState> emit,
  ) async {
    emit(state.copyWith(status: MembershipStateStatus.processing));

    try {
      // Simular procesamiento de pago (2-3 segundos)
      await Future.delayed(const Duration(seconds: 2));

      // En producción, aquí se conectaría con Stripe/PayPal/MercadoPago
      // Por ahora simulamos éxito
      final transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      
      final newMembership = Membership(
        id: 'membership_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        plan: state.selectedPlan,
        status: MembershipStatus.active,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: state.selectedPlan.durationDays)),
        transactionId: transactionId,
        paymentMethod: state.selectedPaymentMethod,
      );

      // Guardar en preferencias
      await _prefs.setBool(_isPremiumKey, true);
      await _prefs.setString(_membershipKey, 'active');

      emit(state.copyWith(
        status: MembershipStateStatus.success,
        currentMembership: newMembership,
        lastPaymentResult: PaymentResult.success(transactionId),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MembershipStateStatus.error,
        errorMessage: 'Error al procesar el pago: $e',
        lastPaymentResult: PaymentResult.failure(e.toString()),
      ));
    }
  }

  Future<void> _onCancelMembership(
    CancelMembershipEvent event,
    Emitter<MembershipState> emit,
  ) async {
    emit(state.copyWith(status: MembershipStateStatus.processing));

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Cancelar membresía
      await _prefs.setBool(_isPremiumKey, false);
      await _prefs.remove(_membershipKey);

      final cancelledMembership = Membership(
        id: state.currentMembership?.id ?? '',
        userId: state.currentMembership?.userId ?? '',
        plan: state.currentMembership?.plan ?? MembershipPlan.monthly,
        status: MembershipStatus.cancelled,
        startDate: state.currentMembership?.startDate ?? DateTime.now(),
        endDate: state.currentMembership?.endDate ?? DateTime.now(),
        cancelledAt: DateTime.now(),
      );

      emit(state.copyWith(
        status: MembershipStateStatus.loaded,
        currentMembership: cancelledMembership,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MembershipStateStatus.error,
        errorMessage: 'Error al cancelar membresía: $e',
      ));
    }
  }

  Future<void> _onRestorePurchase(
    RestorePurchaseEvent event,
    Emitter<MembershipState> emit,
  ) async {
    emit(state.copyWith(status: MembershipStateStatus.processing));

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Simular restauración (en producción verificaría con el servidor)
      emit(state.copyWith(
        status: MembershipStateStatus.loaded,
        errorMessage: 'No se encontraron compras anteriores',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MembershipStateStatus.error,
        errorMessage: 'Error al restaurar compra: $e',
      ));
    }
  }

  /// Verificar si el usuario es premium (método estático para uso rápido)
  static Future<bool> checkPremiumStatus(SharedPreferences prefs) async {
    return prefs.getBool(_isPremiumKey) ?? false;
  }
}

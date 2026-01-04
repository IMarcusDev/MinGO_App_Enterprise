import 'package:equatable/equatable.dart';

/// Modelo de membresía/suscripción
class Membership extends Equatable {
  final String id;
  final String userId;
  final MembershipPlan plan;
  final MembershipStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? cancelledAt;
  final String? transactionId;
  final PaymentMethod? paymentMethod;

  const Membership({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.cancelledAt,
    this.transactionId,
    this.paymentMethod,
  });

  bool get isActive => 
      status == MembershipStatus.active && 
      DateTime.now().isBefore(endDate);

  int get daysRemaining => 
      endDate.difference(DateTime.now()).inDays;

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      plan: MembershipPlan.fromString(json['plan'] ?? 'monthly'),
      status: MembershipStatus.fromString(json['status'] ?? 'inactive'),
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at']) 
          : null,
      transactionId: json['transaction_id'],
      paymentMethod: json['payment_method'] != null
          ? PaymentMethod.fromString(json['payment_method'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan': plan.value,
      'status': status.value,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'transaction_id': transactionId,
      'payment_method': paymentMethod?.value,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        plan,
        status,
        startDate,
        endDate,
        cancelledAt,
        transactionId,
        paymentMethod,
      ];
}

/// Plan de membresía disponible
enum MembershipPlan {
  monthly('monthly', 'Mensual', 4.99, 30),
  quarterly('quarterly', 'Trimestral', 11.99, 90),
  yearly('yearly', 'Anual', 39.99, 365);

  final String value;
  final String displayName;
  final double price;
  final int durationDays;

  const MembershipPlan(this.value, this.displayName, this.price, this.durationDays);

  static MembershipPlan fromString(String value) {
    return MembershipPlan.values.firstWhere(
      (p) => p.value == value,
      orElse: () => MembershipPlan.monthly,
    );
  }

  String get priceFormatted => '\$${price.toStringAsFixed(2)}';
  
  double get monthlyEquivalent {
    switch (this) {
      case MembershipPlan.monthly:
        return price;
      case MembershipPlan.quarterly:
        return price / 3;
      case MembershipPlan.yearly:
        return price / 12;
    }
  }
  
  int get savingsPercent {
    final monthlyTotal = MembershipPlan.monthly.price * (durationDays / 30);
    return ((1 - (price / monthlyTotal)) * 100).round();
  }
}

/// Estado de la membresía
enum MembershipStatus {
  active('active', 'Activa'),
  inactive('inactive', 'Inactiva'),
  expired('expired', 'Expirada'),
  cancelled('cancelled', 'Cancelada'),
  pending('pending', 'Pendiente');

  final String value;
  final String displayName;

  const MembershipStatus(this.value, this.displayName);

  static MembershipStatus fromString(String value) {
    return MembershipStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => MembershipStatus.inactive,
    );
  }
}

/// Método de pago
enum PaymentMethod {
  stripe('stripe', 'Tarjeta de Crédito/Débito'),
  paypal('paypal', 'PayPal'),
  mercadopago('mercadopago', 'MercadoPago');

  final String value;
  final String displayName;

  const PaymentMethod(this.value, this.displayName);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (m) => m.value == value,
      orElse: () => PaymentMethod.stripe,
    );
  }

  String get iconAsset {
    switch (this) {
      case PaymentMethod.stripe:
        return 'assets/icons/stripe.png';
      case PaymentMethod.paypal:
        return 'assets/icons/paypal.png';
      case PaymentMethod.mercadopago:
        return 'assets/icons/mercadopago.png';
    }
  }
}

/// Beneficios de la membresía premium
class PremiumBenefits {
  static const List<PremiumBenefit> benefits = [
    PremiumBenefit(
      icon: '🔤',
      title: 'Traductor de Señas',
      description: 'Traduce palabras y frases a Lengua de Señas Ecuatoriana',
    ),
    PremiumBenefit(
      icon: '🎮',
      title: 'Aprendizaje Dinámico',
      description: 'Juegos interactivos de memoria e imitación',
    ),
    PremiumBenefit(
      icon: '📚',
      title: 'Contenido Exclusivo',
      description: 'Acceso a módulos y lecciones avanzadas',
    ),
    PremiumBenefit(
      icon: '📊',
      title: 'Estadísticas Detalladas',
      description: 'Análisis profundo de tu progreso de aprendizaje',
    ),
    PremiumBenefit(
      icon: '🔄',
      title: 'Sin Anuncios',
      description: 'Experiencia de aprendizaje sin interrupciones',
    ),
    PremiumBenefit(
      icon: '⬇️',
      title: 'Descarga Ilimitada',
      description: 'Descarga todo el contenido para uso sin conexión',
    ),
  ];
}

/// Beneficio individual
class PremiumBenefit extends Equatable {
  final String icon;
  final String title;
  final String description;

  const PremiumBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [icon, title, description];
}

/// Resultado de transacción de pago
class PaymentResult extends Equatable {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final DateTime timestamp;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    required this.timestamp,
  });

  factory PaymentResult.success(String transactionId) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      timestamp: DateTime.now(),
    );
  }

  factory PaymentResult.failure(String errorMessage) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [success, transactionId, errorMessage, timestamp];
}

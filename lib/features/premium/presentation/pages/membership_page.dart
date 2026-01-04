import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/config/routes.dart';
import '../../domain/entities/membership_entities.dart';
import '../bloc/membership_bloc.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  @override
  void initState() {
    super.initState();
    context.read<MembershipBloc>().add(const LoadMembershipEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MembershipBloc, MembershipState>(
        listener: (context, state) {
          if (state.status == MembershipStateStatus.success) {
            _showSuccessDialog(context, state);
          }
          if (state.status == MembershipStateStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // Si ya es premium, mostrar estado de membresía
          if (state.isPremium) {
            return _buildPremiumStatus(context, state);
          }

          return _buildPurchasePage(context, state);
        },
      ),
    );
  }

  Widget _buildPurchasePage(BuildContext context, MembershipState state) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.workspace_premium, size: 64, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      'MinGO Premium',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Desbloquea todo el contenido',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Beneficios
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Beneficios Premium', style: AppTypography.titleLarge),
                const SizedBox(height: AppDimensions.space),
                ...PremiumBenefits.benefits.asMap().entries.map((entry) {
                  return AnimatedFadeIn(
                    delay: Duration(milliseconds: 100 * entry.key),
                    child: _buildBenefitItem(entry.value),
                  );
                }),
              ],
            ),
          ),
        ),

        // Planes
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elige tu plan', style: AppTypography.titleLarge),
                const SizedBox(height: AppDimensions.space),
                ...MembershipPlan.values.map((plan) {
                  return _buildPlanCard(context, plan, state);
                }),
              ],
            ),
          ),
        ),

        // Métodos de pago
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Método de pago', style: AppTypography.titleLarge),
                const SizedBox(height: AppDimensions.space),
                _buildPaymentMethods(context, state),
              ],
            ),
          ),
        ),

        // Botón de compra
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.status == MembershipStateStatus.processing
                        ? null
                        : () {
                            context
                                .read<MembershipBloc>()
                                .add(const ProcessPaymentEvent());
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.premium,
                    ),
                    child: state.status == MembershipStateStatus.processing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Suscribirse por ${state.selectedPlan.priceFormatted}/mes',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space),
                TextButton(
                  onPressed: () {
                    context.read<MembershipBloc>().add(const RestorePurchaseEvent());
                  },
                  child: const Text('Restaurar compra'),
                ),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  'Al suscribirte, aceptas nuestros términos y condiciones.\nPuedes cancelar en cualquier momento.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceXL),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(PremiumBenefit benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(benefit.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(benefit.title, style: AppTypography.titleSmall),
                Text(
                  benefit.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    MembershipPlan plan,
    MembershipState state,
  ) {
    final isSelected = state.selectedPlan == plan;
    final isBestValue = plan == MembershipPlan.yearly;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: AnimatedPressable(
        onTap: () {
          context.read<MembershipBloc>().add(SelectPlanEvent(plan));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppDimensions.space),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.dividerLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Radio button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),

              // Info del plan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(plan.displayName, style: AppTypography.titleMedium),
                        if (isBestValue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Mejor valor',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.durationDays} días',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Precio
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.priceFormatted,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (plan.savingsPercent > 0)
                    Text(
                      'Ahorra ${plan.savingsPercent}%',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context, MembershipState state) {
    return Row(
      children: PaymentMethod.values.map((method) {
        final isSelected = state.selectedPaymentMethod == method;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedPressable(
              onTap: () {
                context.read<MembershipBloc>().add(SelectPaymentMethodEvent(method));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.dividerLight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getPaymentIcon(method),
                      size: 32,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.displayName.split(' ').first,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.stripe:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.mercadopago:
        return Icons.payments;
    }
  }

  Widget _buildPremiumStatus(BuildContext context, MembershipState state) {
    final membership = state.currentMembership!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.premium, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¡Eres Premium!',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            child: Column(
              children: [
                // Estado de membresía
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space),
                    child: Column(
                      children: [
                        _buildStatusRow(
                          'Plan',
                          membership.plan.displayName,
                          Icons.card_membership,
                        ),
                        const Divider(),
                        _buildStatusRow(
                          'Estado',
                          membership.status.displayName,
                          Icons.check_circle,
                          valueColor: AppColors.success,
                        ),
                        const Divider(),
                        _buildStatusRow(
                          'Días restantes',
                          '${membership.daysRemaining} días',
                          Icons.timer,
                        ),
                        const Divider(),
                        _buildStatusRow(
                          'Vence el',
                          '${membership.endDate.day}/${membership.endDate.month}/${membership.endDate.year}',
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceL),

                // Accesos rápidos
                Text('Contenido Exclusivo', style: AppTypography.titleLarge),
                const SizedBox(height: AppDimensions.space),
                
                _buildPremiumFeatureCard(
                  context,
                  icon: Icons.translate,
                  title: 'Traductor de Señas',
                  subtitle: 'Traduce palabras y frases',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.translator),
                ),
                _buildPremiumFeatureCard(
                  context,
                  icon: Icons.games,
                  title: 'Aprendizaje Dinámico',
                  subtitle: 'Juegos interactivos',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.dynamicLearning),
                ),

                const SizedBox(height: AppDimensions.spaceL),
                TextButton(
                  onPressed: () => _showCancelDialog(context),
                  child: const Text(
                    'Cancelar suscripción',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.premium.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.premium),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, MembershipState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        title: const Text('¡Bienvenido a Premium!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tu suscripción se ha activado correctamente. Ahora tienes acceso a todo el contenido exclusivo.',
              textAlign: TextAlign.center,
            ),
            if (state.lastPaymentResult?.transactionId != null) ...[
              const SizedBox(height: 16),
              Text(
                'ID: ${state.lastPaymentResult!.transactionId}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('¡Comenzar!'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar tu suscripción? '
          'Mantendrás el acceso hasta el final del período actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MembershipBloc>().add(const CancelMembershipEvent());
            },
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

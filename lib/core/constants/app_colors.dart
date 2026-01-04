import 'package:flutter/material.dart';

/// Colores de la aplicación con soporte para tema claro y oscuro
class AppColors {
  // ============================================
  // COLORES PRINCIPALES (Invariantes)
  // ============================================
  
  // Primary
  static const Color primary = Color(0xFF0099FF);
  static const Color primaryDark = Color(0xFF0A4D8C);
  static const Color primaryLight = Color(0xFF66C2FF);
  
  // Secondary
  static const Color secondary = Color(0xFF6C63FF);
  static const Color secondaryDark = Color(0xFF4B44B2);
  static const Color secondaryLight = Color(0xFF9D97FF);
  
  // Status (mismos en ambos temas)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);
  
  // Levels (mismos en ambos temas)
  static const Color levelPrincipiante = Color(0xFF2196F3);
  static const Color levelIntermedio = Color(0xFFFF9800);
  static const Color levelAvanzado = Color(0xFF4CAF50);
  
  // Premium
  static const Color premium = Color(0xFF9C27B0);
  static const Color premiumLight = Color(0xFFE1BEE7);
  static const Color premiumDark = Color(0xFF6A1B9A);
  
  // ============================================
  // COLORES TEMA CLARO
  // ============================================
  
  // Background Light
  static const Color backgroundLight = Color(0xFFF5F9FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Text Light
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textHintLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border Light
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFE5E7EB);
  
  // Shadow Light
  static const Color shadowLight = Color(0x1A000000);
  
  // ============================================
  // COLORES TEMA OSCURO
  // ============================================
  
  // Background Dark
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF252540);
  
  // Text Dark
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textHintDark = Color(0xFF6B7280);
  static const Color textOnDark = Color(0xFFFFFFFF);
  
  // Border Dark
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerDark = Color(0xFF374151);
  
  // Shadow Dark
  static const Color shadowDark = Color(0x40000000);
  
  // ============================================
  // ALIASES PARA COMPATIBILIDAD
  // ============================================
  
  // Estos se mantienen para no romper código existente
  // Apuntan a los valores de tema claro por defecto
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textHint = textHintLight;
  static const Color border = borderLight;
  static const Color shadow = shadowLight;
  static const Color borderFocused = primary;
  
  // ============================================
  // GRADIENTS
  // ============================================
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================
  // HELPERS
  // ============================================
  
  /// Obtener color según nivel
  static Color getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'PRINCIPIANTE':
        return levelPrincipiante;
      case 'INTERMEDIO':
        return levelIntermedio;
      case 'AVANZADO':
        return levelAvanzado;
      default:
        return primary;
    }
  }
  
  /// Obtener color con opacidad para fondos
  static Color withLightOpacity(Color color) => color.withOpacity(0.1);
  static Color withMediumOpacity(Color color) => color.withOpacity(0.2);
}

/// Extension para obtener colores según el tema actual
extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  Color get backgroundColor => isDarkMode 
      ? AppColors.backgroundDark 
      : AppColors.backgroundLight;
  
  Color get surfaceColor => isDarkMode 
      ? AppColors.surfaceDark 
      : AppColors.surfaceLight;
  
  Color get cardColor => isDarkMode 
      ? AppColors.cardDark 
      : AppColors.cardLight;
  
  Color get textPrimaryColor => isDarkMode 
      ? AppColors.textPrimaryDark 
      : AppColors.textPrimaryLight;
  
  Color get textSecondaryColor => isDarkMode 
      ? AppColors.textSecondaryDark 
      : AppColors.textSecondaryLight;
  
  Color get textHintColor => isDarkMode 
      ? AppColors.textHintDark 
      : AppColors.textHintLight;
  
  Color get borderColor => isDarkMode 
      ? AppColors.borderDark 
      : AppColors.borderLight;
  
  Color get dividerColor => isDarkMode 
      ? AppColors.dividerDark 
      : AppColors.dividerLight;
  
  Color get shadowColor => isDarkMode 
      ? AppColors.shadowDark 
      : AppColors.shadowLight;
}

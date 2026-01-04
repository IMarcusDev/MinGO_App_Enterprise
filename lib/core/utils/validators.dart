/// Validadores de formularios
class Validators {
  /// Validar email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  /// Validar contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    
    return null;
  }

  /// Validar contraseña fuerte
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una mayúscula';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe contener al menos una minúscula';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener al menos un número';
    }
    
    return null;
  }

  /// Validar confirmación de contraseña
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Confirma tu contraseña';
      }
      
      if (value != password) {
        return 'Las contraseñas no coinciden';
      }
      
      return null;
    };
  }

  /// Validar nombre
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.length < 2) {
      return 'Mínimo 2 caracteres';
    }
    
    if (value.length > 100) {
      return 'Máximo 100 caracteres';
    }
    
    return null;
  }

  /// Validar campo requerido
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  /// Validar longitud mínima
  static String? Function(String?) minLength(int min, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? 'Este campo'} es requerido';
      }
      
      if (value.length < min) {
        return 'Mínimo $min caracteres';
      }
      
      return null;
    };
  }

  /// Validar longitud máxima
  static String? Function(String?) maxLength(int max, [String? fieldName]) {
    return (String? value) {
      if (value != null && value.length > max) {
        return 'Máximo $max caracteres';
      }
      return null;
    };
  }

  /// Validar número de teléfono
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // El teléfono es opcional
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Ingresa un número válido';
    }
    
    return null;
  }

  /// Validar edad del niño (0-17)
  static String? childAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'La edad es requerida';
    }
    
    final age = int.tryParse(value);
    
    if (age == null) {
      return 'Ingresa un número válido';
    }
    
    if (age < 0 || age > 17) {
      return 'La edad debe estar entre 0 y 17 años';
    }
    
    return null;
  }

  /// Calcular fuerza de la contraseña (0-4)
  static int passwordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    return strength.clamp(0, 4);
  }
}

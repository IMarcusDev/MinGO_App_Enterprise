import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================
// EVENTS
// ============================================
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

class SetThemeModeEvent extends ThemeEvent {
  final ThemeMode mode;
  const SetThemeModeEvent(this.mode);
  @override
  List<Object?> get props => [mode];
}

// ============================================
// STATE
// ============================================
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  
  const ThemeState({this.themeMode = ThemeMode.system});
  
  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isSystemMode => themeMode == ThemeMode.system;
  
  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }
  
  @override
  List<Object?> get props => [themeMode];
}

// ============================================
// BLOC
// ============================================
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  
  ThemeBloc({required SharedPreferences prefs}) 
      : _prefs = prefs,
        super(const ThemeState()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeModeEvent>(_onSetThemeMode);
  }

  void _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) {
    final savedTheme = _prefs.getString(_themeKey);
    
    ThemeMode mode;
    switch (savedTheme) {
      case 'dark':
        mode = ThemeMode.dark;
        break;
      case 'light':
        mode = ThemeMode.light;
        break;
      default:
        mode = ThemeMode.system;
    }
    
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event, 
    Emitter<ThemeState> emit,
  ) async {
    final newMode = state.themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    
    await _saveTheme(newMode);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> _onSetThemeMode(
    SetThemeModeEvent event, 
    Emitter<ThemeState> emit,
  ) async {
    await _saveTheme(event.mode);
    emit(state.copyWith(themeMode: event.mode));
  }
  
  Future<void> _saveTheme(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.light:
        value = 'light';
        break;
      default:
        value = 'system';
    }
    await _prefs.setString(_themeKey, value);
  }
}

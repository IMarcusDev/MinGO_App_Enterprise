import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/app_colors.dart';

/// Widget que muestra un banner cuando no hay conexión
class ConnectivityIndicator extends StatefulWidget {
  final Widget child;
  final bool showWhenConnected;

  const ConnectivityIndicator({
    super.key,
    required this.child,
    this.showWhenConnected = false,
  });

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isConnected = true;
  bool _showBanner = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;

    if (mounted) {
      setState(() {
        _isConnected = connected;
        _showBanner = !connected || widget.showWhenConnected;
      });

      if (_showBanner && !connected) {
        _animationController.forward();
      } else if (connected) {
        // Mostrar brevemente mensaje de reconexión
        _animationController.forward().then((_) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && _isConnected) {
              _animationController.reverse();
            }
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _animation,
          child: _buildBanner(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: _isConnected ? AppColors.success : AppColors.error,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _isConnected 
                  ? 'Conexión restaurada' 
                  : 'Sin conexión - Modo offline',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!_isConnected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Datos en caché',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget simple de icono de estado de conexión
class ConnectionStatusIcon extends StatefulWidget {
  final double size;
  final Color? connectedColor;
  final Color? disconnectedColor;

  const ConnectionStatusIcon({
    super.key,
    this.size = 20,
    this.connectedColor,
    this.disconnectedColor,
  });

  @override
  State<ConnectionStatusIcon> createState() => _ConnectionStatusIconState();
}

class _ConnectionStatusIconState extends State<ConnectionStatusIcon> {
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _isConnected ? Icons.cloud_done : Icons.cloud_off,
      size: widget.size,
      color: _isConnected
          ? (widget.connectedColor ?? AppColors.success)
          : (widget.disconnectedColor ?? AppColors.error),
    );
  }
}

/// Wrapper para mostrar snackbar de estado offline
class OfflineAwareBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isOnline) builder;

  const OfflineAwareBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<OfflineAwareBuilder> createState() => _OfflineAwareBuilderState();
}

class _OfflineAwareBuilderState extends State<OfflineAwareBuilder> {
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final connected = result != ConnectivityResult.none;

      if (mounted && _isConnected != connected) {
        setState(() => _isConnected = connected);

        // Mostrar snackbar al cambiar estado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  connected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(connected
                    ? 'Conexión restaurada'
                    : 'Sin conexión - Usando datos guardados'),
              ],
            ),
            backgroundColor: connected ? AppColors.success : AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isConnected);
  }
}

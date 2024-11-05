import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../theme/theme_constants.dart';

class ButtonWidget extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Duration loadingDuration;

  const ButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.loadingDuration = const Duration(milliseconds: 1500),
  });

  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLocalLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLocalLoading || widget.isLoading) return;

    _animationController.forward();

    setState(() => _isLocalLoading = true);

    // Simulate loading time if onPressed is null
    if (widget.onPressed == null) {
      await Future.delayed(widget.loadingDuration);
    } else {
      await Future.microtask(() => widget.onPressed!());
    }

    if (mounted) {
      setState(() => _isLocalLoading = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = widget.isLoading || _isLocalLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: ThemeConstants.standardWidth,
              height: ThemeConstants.standardHeight,
              decoration: BoxDecoration(
                color: isLoading
                    ? theme.colorScheme.primary.withOpacity(0.9)
                    : theme.colorScheme.primary,
                borderRadius: ThemeConstants.standardBorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: ThemeConstants.standardPadding,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage:

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme_constants.dart';

class TextFieldWidget extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool showCharacterCount;

  const TextFieldWidget({
    super.key,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.inputFormatters,
    this.maxLength,
    this.showCharacterCount = false,
  });

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  bool _isHovered = false;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = widget.validator?.call(widget.controller?.text);
    final hasError = errorText != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: ThemeConstants.standardWidth,
          height: ThemeConstants.standardHeight +
              (hasError ? 24 : 0) +
              (widget.labelText != null ? 20 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.labelText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    widget.labelText!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _isFocused
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Container(
                height: ThemeConstants.standardHeight,
                decoration: BoxDecoration(
                  color: _isFocused
                      ? theme.colorScheme.surface
                      : theme.colorScheme.surface.withOpacity(0.8),
                  borderRadius: ThemeConstants.standardBorderRadius,
                  border: Border.all(
                    color: hasError
                        ? theme.colorScheme.error
                        : _isFocused
                        ? theme.colorScheme.primary
                        : _isHovered
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : theme.colorScheme.outline.withOpacity(0.2),
                    width: _isFocused ? 2 : 1,
                  ),
                  boxShadow: [
                    if (_isFocused)
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    if (_isHovered && !_isFocused)
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TextField(
                      focusNode: _focusNode,
                      controller: widget.controller,
                      keyboardType: widget.keyboardType,
                      obscureText: _isObscured,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      inputFormatters: widget.inputFormatters,
                      maxLength: widget.maxLength,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          left: widget.prefixIcon != null ? 48 : 16,
                          right: widget.suffixIcon != null ? 48 : 16,
                        ),
                        hintStyle: TextStyle(
                          color: _isFocused
                              ? theme.hintColor
                              : theme.hintColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    if (widget.prefixIcon != null)
                      Positioned(
                        left: 12,
                        child: Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                    if (widget.suffixIcon != null || widget.obscureText)
                      Positioned(
                        right: 12,
                        child: IconButton(
                          icon: Icon(
                            widget.obscureText
                                ? (_isObscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded)
                                : widget.suffixIcon!,
                            size: 20,
                          ),
                          color: _isFocused
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                          onPressed: widget.obscureText
                              ? () => setState(() => _isObscured = !_isObscured)
                              : widget.onSuffixIconPressed,
                          splashRadius: 20,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasError)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: theme.colorScheme.error,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          errorText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (widget.showCharacterCount && widget.maxLength != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Text(
                      '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Example usage:

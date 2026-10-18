import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../services/audio_service.dart';

/// 3D Cartoon Tactile Push Button - NO ICONS!
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool isFullWidth;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.isFullWidth = true,
    this.height = 54,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? AppColors.primary;
    final hsl = HSLColor.fromColor(baseColor);
    final darkShadowColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: widget.isFullWidth ? double.infinity : null,
        height: widget.height,
        margin: EdgeInsets.only(top: _isPressed ? 4.0 : 0.0, bottom: _isPressed ? 0.0 : 4.0),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(widget.height / 2.2),
          border: Border.all(color: AppColors.cartoonBorder, width: 2.2),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: darkShadowColor,
                    offset: const Offset(0, 4.5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// 3D Cartoon Secondary Button - NO ICONS!
class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final double height;
  final Color? color;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = true,
    this.height = 54,
    this.color,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: widget.isFullWidth ? double.infinity : null,
        height: widget.height,
        margin: EdgeInsets.only(top: _isPressed ? 3.0 : 0.0, bottom: _isPressed ? 0.0 : 3.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.height / 2.2),
          border: Border.all(color: textColor, width: 2.2),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: textColor.withOpacity(0.35),
                    offset: const Offset(0, 3.5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// Candy Tube Progress Bar
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final double height;
  final Color? backgroundColor;

  const ProgressBar({
    super.key,
    required this.progress,
    this.color = AppColors.success,
    this.height = 14,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness - 0.1).clamp(0.0, 1.0)).toColor(),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
          // Glossy shine reflection on top
          Positioned(
            top: 2,
            left: 4,
            right: 4,
            height: height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartoon Card with 3D Depth
class CartoonCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const CartoonCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? const Color(0xFFD6E4FF), width: 2.2),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? const Color(0xFFD0E1FD),
            offset: const Offset(0, 4.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }
    return cardContent;
  }
}

/// Cartoon Audio Speak Bubble Button
class AudioButton extends StatefulWidget {
  final String textToSpeak;
  final String? label;
  final bool isCompact;

  const AudioButton({
    super.key,
    required this.textToSpeak,
    this.label,
    this.isCompact = false,
  });

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _audioService.addListener(_onAudioChanged);
  }

  void _onAudioChanged() {
    if (mounted) {
      if (_isPlaying) {
        if (!_controller.isAnimating) {
          _controller.repeat(reverse: true);
        }
      } else {
        if (_controller.isAnimating) {
          _controller.stop();
          _controller.reset();
        }
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioChanged);
    _controller.dispose();
    super.dispose();
  }

  bool get _isPlaying => _audioService.isSpeaking(widget.textToSpeak);

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioService.stop();
    } else {
      await _audioService.speak(widget.textToSpeak);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _isPlaying;
    final defaultLabel = widget.label ?? 'NGHE';

    return GestureDetector(
      onTap: _togglePlay,
      child: AnimatedScale(
        scale: isPlaying ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 10 : 14,
            vertical: widget.isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isPlaying ? AppColors.accentLight : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPlaying ? AppColors.accent : const Color(0xFFD6E4FF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isPlaying ? AppColors.accent.withOpacity(0.3) : const Color(0xFFD0E1FD),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                size: widget.isCompact ? 16 : 18,
                color: isPlaying ? AppColors.accentDark : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                isPlaying ? 'ĐANG ĐỌC...' : defaultLabel,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: widget.isCompact ? 11 : 12,
                  fontWeight: FontWeight.w900,
                  color: isPlaying ? AppColors.accentDark : AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

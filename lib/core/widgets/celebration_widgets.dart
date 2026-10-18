import 'package:flutter/material.dart';

// --- Text Khen Ngợi Animation ---
class CelebrationText extends StatefulWidget {
  final String text;
  final VoidCallback onComplete;

  const CelebrationText({super.key, required this.text, required this.onComplete});

  @override
  State<CelebrationText> createState() => _CelebrationTextState();
}

class _CelebrationTextState extends State<CelebrationText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.amber,
              shadows: [
                Shadow(blurRadius: 10, color: Colors.black26, offset: Offset(0, 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Điểm bay lên Animation ---
class ScoreAnimation extends StatefulWidget {
  final int score;
  final VoidCallback onComplete;

  const ScoreAnimation({super.key, required this.score, required this.onComplete});

  @override
  State<ScoreAnimation> createState() => _ScoreAnimationState();
}

class _ScoreAnimationState extends State<ScoreAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.5)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 50),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Text(
              '+${widget.score} điểm',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                shadows: [
                  Shadow(blurRadius: 8, color: Colors.white, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Mascot Cổ Vũ Animation ---
class CelebrationCharacter extends StatefulWidget {
  final bool isCorrect;

  const CelebrationCharacter({super.key, required this.isCorrect});

  @override
  State<CelebrationCharacter> createState() => _CelebrationCharacterState();
}

class _CelebrationCharacterState extends State<CelebrationCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    if (widget.isCorrect) {
      _jumpAnimation = TweenSequence([
        TweenSequenceItem(tween: Tween<double>(begin: 0, end: -20).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
        TweenSequenceItem(tween: Tween<double>(begin: -20, end: 0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
      ]).animate(_controller);
      _controller.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) _controller.stop();
      });
    } else {
      // Wiggle nhẹ khi sai
      _jumpAnimation = TweenSequence([
        TweenSequenceItem(tween: Tween<double>(begin: 0, end: 10), weight: 25),
        TweenSequenceItem(tween: Tween<double>(begin: 10, end: -10), weight: 50),
        TweenSequenceItem(tween: Tween<double>(begin: -10, end: 0), weight: 25),
      ]).animate(_controller);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _jumpAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.isCorrect ? 0 : _jumpAnimation.value, widget.isCorrect ? _jumpAnimation.value : 0),
          child: child,
        );
      },
      child: Center(
        child: Text(
          widget.isCorrect ? '🎉' : '🤔',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }
}

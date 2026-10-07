import 'package:flutter/material.dart';

/// Entrada animada: aparece con fade + desplazamiento vertical sutil.
///
/// Pensada para composiciones escalonadas (stagger): cada elemento recibe
/// un [delay] creciente y la lista entera se siente coreografiada.
class FadeInSlide extends StatefulWidget {
  const FadeInSlide({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.offset = 24,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Desplazamiento inicial en píxeles (de abajo hacia arriba).
  final double offset;

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = curve;
    _slide = Tween<double>(begin: widget.offset, end: 0).animate(curve);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Helper para escalonar una lista de widgets con FadeInSlide.
List<Widget> staggered(
  List<Widget> children, {
  Duration step = const Duration(milliseconds: 80),
  Duration initialDelay = Duration.zero,
}) {
  return [
    for (var i = 0; i < children.length; i++)
      FadeInSlide(
        delay: initialDelay + step * i,
        child: children[i],
      ),
  ];
}

import 'package:flutter/material.dart';

class DraggableBottomSheet extends StatefulWidget {
  final double minTop;
  final double maxTop;
  final Widget child;

  const DraggableBottomSheet({
    super.key,
    required this.minTop,
    required this.maxTop,
    required this.child,
  });

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet>
    with SingleTickerProviderStateMixin {
  late double _currentTop;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentTop = widget.minTop;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.addListener(() {
      setState(() {
        _currentTop = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    setState(() {
      _currentTop += details.delta.dy;
      if (_currentTop < widget.minTop) {
        _currentTop = widget.minTop;
      } else if (_currentTop > widget.maxTop) {
        _currentTop = widget.maxTop;
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final double targetTop;
    final double velocity = details.primaryVelocity ?? 0;

    // Si el arrastre fue rápido, usamos la velocidad para decidir
    if (velocity > 300) {
      targetTop = widget.maxTop;
    } else if (velocity < -300) {
      targetTop = widget.minTop;
    } else {
      // Si fue lento, encajamos según la mitad del camino
      final middle = (widget.minTop + widget.maxTop) / 2;
      targetTop = _currentTop < middle ? widget.minTop : widget.maxTop;
    }

    _animation = Tween<double>(begin: _currentTop, end: targetTop).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _currentTop,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

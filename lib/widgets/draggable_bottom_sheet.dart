import 'package:flutter/material.dart';

class DraggableBottomSheet extends StatefulWidget {
  final double minTop;
  final double maxTop;
  final Widget child;
  final ValueChanged<double>? onPositionChanged;
  final ValueChanged<bool>? onExpansionChanged;

  const DraggableBottomSheet({
    super.key,
    required this.minTop,
    required this.maxTop,
    required this.child,
    this.onPositionChanged,
    this.onExpansionChanged,
  });

  @override
  State<DraggableBottomSheet> createState() => DraggableBottomSheetState();
}

class DraggableBottomSheetState extends State<DraggableBottomSheet>
    with SingleTickerProviderStateMixin {
  late double _currentTop;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  void _updateExpansionState() {
    final bool currentlyExpanded = (_currentTop - widget.maxTop).abs() < 0.01;
    final bool currentlyCollapsed = (_currentTop - widget.minTop).abs() < 0.01;

    if (currentlyExpanded && !_isExpanded) {
      _isExpanded = true;
      widget.onExpansionChanged?.call(true);
    } else if (currentlyCollapsed && _isExpanded) {
      _isExpanded = false;
      widget.onExpansionChanged?.call(false);
    }
  }

  void expand() {
    if (_controller.isAnimating) _controller.stop();
    _animation = Tween<double>(begin: _currentTop, end: widget.maxTop).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward(from: 0);
  }

  void collapse() {
    if (_controller.isAnimating) _controller.stop();
    _animation = Tween<double>(begin: _currentTop, end: widget.minTop).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward(from: 0);
  }

  void toggle() {
    final middle = (widget.minTop + widget.maxTop) / 2;
    if (_currentTop < middle) {
      expand();
    } else {
      collapse();
    }
  }

  @override
  void initState() {
    super.initState();
    _currentTop = widget.minTop;
    _isExpanded = false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.addListener(() {
      setState(() {
        _currentTop = _animation.value;
      });
      _notifyPosition();
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _updateExpansionState();
      }
    });
  }

  void _notifyPosition() {
    if (widget.onPositionChanged != null) {
      double range = widget.maxTop - widget.minTop;
      if (range > 0) {
        double progress = (_currentTop - widget.minTop) / range;
        widget.onPositionChanged!(progress.clamp(0.0, 1.0));
      }
    }
  }

  @override
  void didUpdateWidget(DraggableBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.minTop != oldWidget.minTop || widget.maxTop != oldWidget.maxTop) {
      if (_currentTop == oldWidget.minTop) {
        _currentTop = widget.minTop;
      } else if (_currentTop == oldWidget.maxTop) {
        _currentTop = widget.maxTop;
      } else {
        // Clamp current top to the new bounds
        if (_currentTop < widget.minTop) _currentTop = widget.minTop;
        if (_currentTop > widget.maxTop) _currentTop = widget.maxTop;
      }
    }
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
    _notifyPosition();
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

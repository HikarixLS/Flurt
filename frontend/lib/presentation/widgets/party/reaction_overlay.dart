import 'package:flutter/material.dart';
import '../../blocs/watch_party/watch_party_state.dart';

class ReactionOverlay extends StatelessWidget {
  final List<ReactionItem> reactions;

  const ReactionOverlay({
    super.key,
    required this.reactions,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: reactions.map((reaction) {
          return _FloatingReactionItem(
            key: ValueKey(reaction.id),
            reaction: reaction,
          );
        }).toList(),
      ),
    );
  }
}

class _FloatingReactionItem extends StatefulWidget {
  final ReactionItem reaction;

  const _FloatingReactionItem({
    super.key,
    required this.reaction,
  });

  @override
  State<_FloatingReactionItem> createState() => _FloatingReactionItemState();
}

class _FloatingReactionItemState extends State<_FloatingReactionItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _yAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _yAnimation = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 55),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.4, end: 1.2), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final xPos = widget.reaction.startX * (constraints.maxWidth - 60);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final yPos = _yAnimation.value * (constraints.maxHeight - 60);

            return Positioned(
              left: xPos,
              top: yPos,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.reaction.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.reaction.senderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  const LikeAnimation(
      {Key? key,
      required this.child,
      this.duration = const Duration(milliseconds: 150),
      required this.isAnimating,
      this.onEnd,
      this.smallLike = false})
      : super(key: key);
  final Widget child;
  //child is to make like animation the parent widget 
  //as in wrapping the icon button 
  final bool isAnimating;
  //as in if it is true start the animation
  final Duration duration;
  //duration tells us that how long the like animation should continue
  final VoidCallback? onEnd;
  //onEnd is called to end the like animation
  final bool smallLike;
  //smallLike is to check if the like button was clicked
  //so if the like button is clicked we can animate

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  //we inherit SingleTickerProviderStateMixin
  //SingleTickerProviderStateMixin allows us to access tween animations and some controllers
  late AnimationController controller;
  late Animation<double> scale;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        //we can use this cus of SingleTickerProviderStateMixin
        duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2));
    //~/ 2 basically divides the milliseconds by 2 and converts it to int

    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }
  }

  startAnimation() async {
    if (widget.isAnimating || widget.smallLike) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(const Duration(milliseconds: 200));

      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}

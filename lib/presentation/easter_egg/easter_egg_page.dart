import 'package:flutter/material.dart';
import 'package:memegenerator/resources/app_colors.dart';
import 'package:memegenerator/resources/app_images.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
        ),
        body: const RocketAnimationBody(),
      );
}

class RocketAnimationBody extends StatefulWidget {
  const RocketAnimationBody({super.key});

  @override
  _RocketAnimationBodyState createState() => _RocketAnimationBodyState();
}

class _RocketAnimationBodyState extends State<RocketAnimationBody>
    with SingleTickerProviderStateMixin {
  static const animationDurationSeconds = 10;
  late AnimationController controller;
  late Animation<Alignment> rocketPositionAnimation;
  late Animation<double> rocketScaleAnimation;
  late Animation<double> fireRotationAnimation;
  late Animation<double> glowScaleAnimation;
  bool started = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: animationDurationSeconds),
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
        setState(() => started = false);
      }
    });
    rocketPositionAnimation = AlignmentTween(
      begin: const Alignment(0, 0.9),
      end: Alignment.topCenter,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInCubic),
      ),
    );
    rocketScaleAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInCubic),
      ),
    );
    fireRotationAnimation = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.005, end: -0.005),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: -0.005, end: 0.005),
          weight: 50,
        ),
      ],
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0,
          0.8,
          curve: SawTooth(animationDurationSeconds * 5),
        ),
      ),
    );
    glowScaleAnimation = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0),
          weight: 50,
        ),
      ],
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.8, 0.9),
      ),
    );
  }

  void animate() {
    if (controller.isAnimating) {
      return;
    }
    setState(() => started = true);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.starsPattern),
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(constraints.maxWidth, 200),
                    ),
                    color: Colors.green[700],
                  ),
                ),
              ),
              if (started)
                AlignTransition(
                  alignment: rocketPositionAnimation,
                  child: RotationTransition(
                    turns: fireRotationAnimation,
                    child: ScaleTransition(
                      scale: rocketScaleAnimation,
                      child: Image.asset(
                        AppImages.rocketFire,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: animate,
                child: AlignTransition(
                  alignment: rocketPositionAnimation,
                  child: ScaleTransition(
                    scale: rocketScaleAnimation,
                    child: Image.asset(
                      AppImages.rocketWithoutFire,
                      height: 200,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 70,
                left: constraints.maxWidth / 2 - 40,
                child: ScaleTransition(
                  scale: glowScaleAnimation,
                  child: Image.asset(
                    AppImages.starGlow,
                    height: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

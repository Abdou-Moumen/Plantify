import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:plant/LandingPage.dart';

class SplashAnimation extends StatefulWidget {
  const SplashAnimation({super.key});

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _circleController;
  late Animation<double> _circleAnimation;

  // Text parts for sequential animation
  final List<String> _textParts = [
    "Start",
    "with the",
    "best",
    "with us",
    "you can",
    "grow",
  ];

  // Colors for background and text
  final List<Color> _bgColors = [
    Colors.black,
    Color(0xFF41734E),
    Colors.black,
    Color(0xFF2D5D4B),
    Colors.black,
    Color(0xFF41734E),
  ];

  final List<Color> _textColors = [
    Colors.white,
    Colors.black,
    Colors.white,
    Colors.white,
    Color(0xFF41734E),
    Colors.white,
  ];

  int _currentTextIndex = -1;
  bool _showCircleTransition = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Circle shrinking animation
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOutQuart),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (!_initialized) {
      _initialized = true;
      _startAnimationSequence();
    }
  }

  void _startAnimationSequence() {
    // Start with circle transition
    _circleController.forward();

    // After circle transition completes, start text sequence
    Future.delayed(Duration(milliseconds: 1400), () {
      setState(() {
        _showCircleTransition = false;
        _currentTextIndex = 0;
      });

      _animateTextSequentially();
    });
  }

  void _animateTextSequentially() {
    if (_currentTextIndex >= _textParts.length - 1) {
      // Animation sequence completed, navigate to landing page
      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => LandingPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 800),
          ),
        );
      });
      return;
    }

    // Move to next text after delay
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _currentTextIndex++;
        });
        _animateTextSequentially();
      }
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _showCircleTransition
              ? _buildCircleTransition(screenWidth, screenHeight)
              : _buildTextSequence(screenWidth, screenHeight),
    );
  }

  Widget _buildCircleTransition(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: _circleController,
      builder: (context, child) {
        return Stack(
          children: [
            // Black background
            Container(
              width: screenWidth,
              height: screenHeight,
              color: Colors.black,
            ),

            // Shrinking circle
            Center(
              child: Container(
                width: screenWidth * (1 - _circleAnimation.value),
                height: screenHeight * (1 - _circleAnimation.value),
                decoration: BoxDecoration(
                  color: Color(0xFF41734E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Opacity(
                    opacity: 1 - _circleAnimation.value,
                    child: Text(
                      "Plant",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48 * (1 - _circleAnimation.value),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextSequence(double screenWidth, double screenHeight) {
    if (_currentTextIndex < 0 || _currentTextIndex >= _textParts.length) {
      return Container();
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 0), // Instant change for jump cut effect
      width: screenWidth,
      height: screenHeight,
      color: _bgColors[_currentTextIndex],
      child: Center(
        child: Text(
          _textParts[_currentTextIndex],
          style: TextStyle(
            color: _textColors[_currentTextIndex],
            fontSize:
                _currentTextIndex == 0 ||
                        _currentTextIndex == _textParts.length - 1
                    ? 60
                    : 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

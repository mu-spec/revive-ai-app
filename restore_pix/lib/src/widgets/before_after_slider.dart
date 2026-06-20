import 'dart:typed_data';
import 'package:flutter/material.dart';

class BeforeAfterSlider extends StatefulWidget {
  final Uint8List beforeImageBytes;
  final Uint8List afterImageBytes;
  final String beforeLabel;
  final String afterLabel;

  const BeforeAfterSlider({
    Key? key,
    required this.beforeImageBytes,
    required this.afterImageBytes,
    this.beforeLabel = 'Damaged',
    this.afterLabel = 'Restored',
  }) : super(key: key);

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPosition = 0.5; // Start exactly in the middle

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _sliderPosition += details.delta.dx / width;
              _sliderPosition = _sliderPosition.clamp(0.02, 0.98);
            });
          },
          child: Stack(
            children: [
              // After Image (Base layer - shows fully or behind clip)
              Positioned(
                left: 0,
                top: 0,
                width: width,
                height: height,
                child: Image.memory(
                  widget.afterImageBytes,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  gaplessPlayback: true,
                ),
              ),

              // Before Image (Clipped by slider position)
              Positioned(
                left: 0,
                top: 0,
                width: width,
                height: height,
                child: ClipRect(
                  clipper: _BeforeClipper(splitFraction: _sliderPosition),
                  child: Image.memory(
                    widget.beforeImageBytes,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    gaplessPlayback: true,
                  ),
                ),
              ),

              // Interactive Divider Line with Glowing Thumb
              Positioned(
                left: _sliderPosition * width - 16, // Center thumb
                top: 0,
                bottom: 0,
                child: Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // White vertical line
                      Container(
                        width: 3,
                        color: Colors.white,
                      ),
                      // Gorgeous Glowing Thumb
                      Container(
                        width: 32,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_left_rounded, color: Color(0xFF7A11FF), size: 16),
                            Icon(Icons.arrow_right_rounded, color: Color(0xFFFF1178), size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Floating Badges ("Before" & "After")
              Positioned(
                left: 16,
                bottom: 24,
                child: AnimatedOpacity(
                  opacity: _sliderPosition > 0.2 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, color: Colors.orangeAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          widget.beforeLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 16,
                bottom: 24,
                child: AnimatedOpacity(
                  opacity: _sliderPosition < 0.8 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7A11FF), Color(0xFFFF1178)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF1178).withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          widget.afterLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BeforeClipper extends CustomClipper<Rect> {
  final double splitFraction;

  _BeforeClipper({required this.splitFraction});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * splitFraction, size.height);
  }

  @override
  bool shouldReclip(_BeforeClipper oldClipper) {
    return oldClipper.splitFraction != splitFraction;
  }
}

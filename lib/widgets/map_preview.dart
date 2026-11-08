import 'package:flutter/material.dart';

/// A lightweight illustrated map used in the demo; it needs no API key.
class MapPreview extends StatelessWidget {
  const MapPreview({super.key, this.destination, this.height = 250});

  final String? destination;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _MapPainter()),
            const Positioned(left: 18, top: 24, child: _MapLabel('SUGAR HILL')),
            const Positioned(right: 16, top: 62, child: _MapLabel('AQUATIC CENTER')),
            const Positioned(left: 20, bottom: 56, child: _MapLabel('WILLOW PARK')),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: CustomPaint(painter: _RoutePainter()),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF20256F),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
            if (destination != null)
              Positioned(
                right: 20,
                bottom: 18,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.place_rounded, color: Color(0xFFB04835), size: 20),
                        const SizedBox(width: 4),
                        Text(destination!, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF42534A),
          fontSize: 10,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w800,
        ),
      );
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFEAF1E6);
    canvas.drawRect(Offset.zero & size, background);

    final parkPaint = Paint()..color = const Color(0xFFD2E7C8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .66, size.height * .13, size.width * .30, size.height * .34),
        const Radius.circular(28),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .04, size.height * .58, size.width * .29, size.height * .30),
        const Radius.circular(26),
      ),
      parkPaint,
    );

    final minorRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final center = Paint()
      ..color = const Color(0xFFF7D78D)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadLine = Paint()
      ..color = const Color(0xFFE8B950)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paths = <Path>[
      Path()..moveTo(-20, size.height * .30)..cubicTo(size.width * .25, size.height * .38, size.width * .38, size.height * .18, size.width + 20, size.height * .36),
      Path()..moveTo(size.width * .08, size.height + 10)..cubicTo(size.width * .34, size.height * .78, size.width * .58, size.height * .51, size.width * .95, -10),
      Path()..moveTo(-10, size.height * .72)..cubicTo(size.width * .4, size.height * .65, size.width * .65, size.height * .83, size.width + 10, size.height * .67),
      Path()..moveTo(size.width * .48, -10)..cubicTo(size.width * .40, size.height * .34, size.width * .76, size.height * .58, size.width * .71, size.height + 10),
    ];
    for (final path in paths) {
      canvas.drawPath(path, minorRoad);
    }
    canvas.drawPath(paths.first, center);
    canvas.drawPath(paths.first, roadLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = const Color(0xFF4654B8)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * .18, size.height * .84)
      ..lineTo(size.width * .30, size.height * .67)
      ..lineTo(size.width * .30, size.height * .48)
      ..lineTo(size.width * .58, size.height * .48)
      ..lineTo(size.width * .58, size.height * .25)
      ..lineTo(size.width * .80, size.height * .18);
    canvas.drawPath(path, route);
    canvas.drawCircle(Offset(size.width * .18, size.height * .84), 7, Paint()..color = const Color(0xFF167A66));
    canvas.drawCircle(Offset(size.width * .80, size.height * .18), 7, Paint()..color = const Color(0xFFB04835));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

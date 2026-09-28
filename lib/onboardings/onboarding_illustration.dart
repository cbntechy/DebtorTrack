import 'package:flutter/material.dart';

enum OnboardingIllustrationType { notebook, calendar, reminder, complete }

class OnboardingIllustration extends StatelessWidget {
  final OnboardingIllustrationType type;

  const OnboardingIllustration({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF463563),
        borderRadius: BorderRadius.circular(48),
      ),
      child: CustomPaint(painter: _OnboardingIllustrationPainter(type)),
    );
  }
}

class _OnboardingIllustrationPainter extends CustomPainter {
  final OnboardingIllustrationType type;

  _OnboardingIllustrationPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case OnboardingIllustrationType.notebook:
        _drawNotebook(canvas, size);
      case OnboardingIllustrationType.calendar:
        _drawCalendar(canvas, size);
      case OnboardingIllustrationType.reminder:
        _drawReminder(canvas, size);
      case OnboardingIllustrationType.complete:
        _drawComplete(canvas, size);
    }
  }

  void _drawNotebook(Canvas canvas, Size size) {
    final page = RRect.fromRectAndRadius(
      Rect.fromCenter(center: size.center(Offset.zero), width: 112, height: 136),
      const Radius.circular(14),
    );
    canvas.drawRRect(page, Paint()..color = const Color(0xFFFFC62D));
    canvas.drawRRect(
      RRect.fromRectAndRadius(page.outerRect.translate(8, 7), const Radius.circular(14)),
      Paint()..color = const Color(0xFFEBAE19),
    );
    final linePaint = Paint()
      ..color = const Color(0xFF855A19)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var y = 72.0; y <= 144; y += 22) {
      canvas.drawLine(Offset(76, y), Offset(154, y), linePaint);
    }
    final ringPaint = Paint()
      ..color = const Color(0xFF65C2D1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    for (var y = 58.0; y <= 160; y += 25) {
      canvas.drawArc(Rect.fromLTWH(45, y, 25, 16), 1.3, 4.2, false, ringPaint);
    }
  }

  void _drawCalendar(Canvas canvas, Size size) {
    final shadow = RRect.fromRectAndRadius(
      const Rect.fromLTWH(54, 51, 122, 126),
      const Radius.circular(18),
    );
    canvas.drawRRect(shadow.shift(const Offset(6, 7)), Paint()..color = const Color(0xFF322546));
    canvas.drawRRect(shadow, Paint()..color = const Color(0xFFFDFBFF));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(54, 51, 122, 38), const Radius.circular(18)),
      Paint()..color = const Color(0xFFEF7065),
    );
    final binder = Paint()
      ..color = const Color(0xFFFFD26F)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(83, 43), const Offset(83, 64), binder);
    canvas.drawLine(const Offset(147, 43), const Offset(147, 64), binder);
    final dot = Paint()..color = const Color(0xFF7652B8);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        canvas.drawCircle(Offset(82 + col * 33, 112 + row * 25), 5, dot);
      }
    }
    canvas.drawCircle(const Offset(148, 137), 13, Paint()..color = const Color(0xFFFFC62D));
  }

  void _drawReminder(Canvas canvas, Size size) {
    final envelope = RRect.fromRectAndRadius(
      const Rect.fromLTWH(42, 77, 136, 89),
      const Radius.circular(14),
    );
    canvas.drawRRect(envelope, Paint()..color = const Color(0xFFFDFBFF));
    final fold = Paint()
      ..color = const Color(0xFF69BDE8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(47, 84)
      ..lineTo(110, 133)
      ..lineTo(173, 84);
    canvas.drawPath(path, fold);
    canvas.drawLine(const Offset(47, 159), const Offset(94, 119), fold);
    canvas.drawLine(const Offset(173, 159), const Offset(126, 119), fold);
    canvas.drawCircle(const Offset(159, 62), 22, Paint()..color = const Color(0xFFEF7065));
    final arrow = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(159, 49), const Offset(159, 71), arrow);
    canvas.drawLine(const Offset(148, 60), const Offset(159, 71), arrow);
    canvas.drawLine(const Offset(170, 60), const Offset(159, 71), arrow);
  }

  void _drawComplete(Canvas canvas, Size size) {
    canvas.drawCircle(size.center(Offset.zero), 65, Paint()..color = const Color(0xFF79C64A));
    canvas.drawCircle(size.center(Offset.zero), 53, Paint()..color = const Color(0xFF8ED55E));
    final check = Paint()
      ..color = Colors.white
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(78, 113)
      ..lineTo(101, 137)
      ..lineTo(146, 86);
    canvas.drawPath(path, check);
    final sparkle = Paint()
      ..color = const Color(0xFFFFD26F)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(49, 58), const Offset(49, 75), sparkle);
    canvas.drawLine(const Offset(40, 66), const Offset(58, 66), sparkle);
    canvas.drawLine(const Offset(173, 148), const Offset(173, 165), sparkle);
    canvas.drawLine(const Offset(164, 156), const Offset(182, 156), sparkle);
  }

  @override
  bool shouldRepaint(covariant _OnboardingIllustrationPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}

import 'package:flutter/material.dart';

class SignalCircleIndicator extends StatelessWidget {
  const SignalCircleIndicator(
      {super.key,
      required this.arcCtlFactor,
      this.arcLengthFactor = .5,
      this.arcColor = Colors.white54});
  final double arcCtlFactor;
  final double arcLengthFactor;
  final Color arcColor;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IndicatorPainter(
          arcCtlFactor: arcCtlFactor,
          arcLengthFactor: arcLengthFactor,
          arcColor: arcColor),
      willChange: true,
      child: Container(),
    );
  }
}

class IndicatorPainter extends CustomPainter {
  IndicatorPainter(
      {required this.arcCtlFactor,
      required this.arcLengthFactor,
      this.strokeWidth = 5,
      required this.arcColor});
  //弧与画布中心的距离 与 画布宽度一半的比例，范围0~1;
  final double arcCtlFactor;
  final double arcLengthFactor;
  final double strokeWidth;
  final Color arcColor;

//TODO 弧长度的一半占画布高度的比例，TODO反映代表星球与玩家的距离，但有最小值，由外部传入？
//最大值跟画布大小有关

  @override
  void paint(Canvas canvas, Size size) {
    var arcLength = (size.height * arcLengthFactor)/2; // TODO 横竖屏问题
    final halfHeight = size.height / 2;
    // 将整个画布的颜色涂成白色
    Paint paint = Paint()..color = Colors.transparent;
    canvas.drawPaint(paint);
    // left part
    final halfarcCtlFactor = arcCtlFactor / 2;
    Path leftPath = Path()
      ..moveTo(size.width * halfarcCtlFactor, halfHeight - arcLength)
      ..arcToPoint(
          Offset(size.width * halfarcCtlFactor, halfHeight + arcLength),
          radius: Radius.elliptical(arcCtlFactor, 1),
          clockwise: false);

    //right part
    Path rightPart = Path()
      ..moveTo(size.width * (1 - halfarcCtlFactor), size.height / 2 - arcLength)
      ..arcToPoint(
          Offset(
              size.width * (1 - halfarcCtlFactor), size.height / 2 + arcLength),
          radius: Radius.elliptical(arcCtlFactor, 1),
          clockwise: true);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = arcColor
      ..strokeWidth = strokeWidth;

    canvas.drawPath(leftPath, strokePaint);
    canvas.drawPath(rightPart, strokePaint);
  }

//TODO 太多setState？用riverpod控制，屏幕外的不更新
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/view_model/indicators_provider.dart';
import 'package:outerwilds_signalscope/widgets/circle_indicator.dart';

class SignalIndicatorView extends ConsumerWidget {
  const SignalIndicatorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("SignalIndicatorView build");
    Widget indicatorGroup;
    List<SignalCircleIndicator> indicators = [];
    final indicatorsData = ref.watch(indicatorListProvider);
    for (var index = 0; index < indicatorsData.length; index++) {
      var indicatorData = indicatorsData[index];
      //TODO 判断是否需要绘制
      // 参数用到两个位置，会rebuild多少次?
      var indicatorWidget = SignalCircleIndicator(
        arcCtlFactor: indicatorData.factor,
        arcLengthFactor: .2,
        arcColor: Colors.white54,
        // arcColor: Color(planets[i].color),
      );
      indicators.add(indicatorWidget);
    }
    indicatorGroup = SizedBox(
      child: Stack(
        children: indicators,
      ),
    );
    return indicatorGroup;
  }
}

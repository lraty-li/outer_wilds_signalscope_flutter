import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/view_model/indicator_list.dart';
import 'package:outerwilds_signalscope/widgets/circle_indicator.dart';

final indicatorListProvider =
    NotifierProvider<IndicatorList, List<IndicatorData>>(IndicatorList.new);

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _initSize(context, homestate);

    return Scaffold(
      body: Stack(
        children: [
          _build3dView(homestate),
          ..._buildIndicators(ref),
        ],
      ),
    );
  }

  _initSize(BuildContext context, HomeState state) async {
    if (state.screenSize != null) {
      return;
    }

    //TODO need setstate to bump frame?
    //state.mySetstate = setState; //TODO better init

    final mqd = MediaQuery.of(context);

    state.screenSize = mqd.size;
    state.dpr = mqd.devicePixelRatio;

    state.mykisweb = kIsWeb;
    await state.initPlatformState();
  }

  List<Visibility> _buildIndicators(WidgetRef ref) {
    {
      List<Visibility> indicators = [];
      var indicatorCount = ref.read(indicatorListProvider).length;
      for (var index = 0; index < indicatorCount; index++) {
        var indicatorData = ref.watch(indicatorListProvider)[index];
        //TODO 判断是否需要绘制
        // 参数用到两个位置，会rebuild多少次?
        var indicatorWidget = Visibility(
          visible: indicatorData.visiablity,
          child: SignalCircleIndicator(
            arcCtlFactor: indicatorData.factor,
            arcLengthFactor: .2,
            arcColor: Colors.red,
            // arcColor: Color(planets[i].color),
          ),
        );
        indicators.add(indicatorWidget);
      }
      return indicators;
    }
  }
}

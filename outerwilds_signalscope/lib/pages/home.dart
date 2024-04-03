import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outerwilds_signalscope/view_model/indicators_provider.dart';
import 'package:outerwilds_signalscope/widgets/circle_indicator.dart';
import 'package:outerwilds_signalscope/widgets/three_demension_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _build(context),
        floatingActionButton: ElevatedButton(
          child: Text("set state"),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _build(BuildContext context) {
    // final rotationVector = ref.watch(rotationProvider);

    return Stack(
      children: [
        ThreeDView(),
        // ..._buildIndicators(ref),
      ],
    );
  }

  // List<Visibility> _buildIndicators(WidgetRef ref) {
  //   {
  //     List<Visibility> indicators = [];
  //     var indicatorCount = ref.read(indicatorListProvider).length;
  //     for (var index = 0; index < indicatorCount; index++) {
  //       var indicatorData = ref.watch(indicatorListProvider)[index];
  //       //TODO 判断是否需要绘制
  //       // 参数用到两个位置，会rebuild多少次?
  //       var indicatorWidget = Visibility(
  //         visible: indicatorData.visiablity,
  //         child: SignalCircleIndicator(
  //           arcCtlFactor: indicatorData.factor,
  //           arcLengthFactor: .2,
  //           arcColor: Colors.red,
  //           // arcColor: Color(planets[i].color),
  //         ),
  //       );
  //       indicators.add(indicatorWidget);
  //     }
  //     return indicators;
  //   }
  // }

  // @override
  // void dispose() {
  //   print(" dispose ............. ");

  //   disposed = true;
  //   homestate.three3dRender.dispose(); //TODO ref dispose

  //   super.dispose();
  // }
}
